require 'instrumentality/executor'
require 'instrumentality/finder'
require 'instrumentality/constants'
require 'instrumentality/simctl'
require 'instrumentality/logger'
require 'net/http'
require 'uri'
require 'tmpdir'

module Instrumentality
  class Profiler
    class ProfilerInterruptError < StandardError; include CLAide::InformativeError; end
    class ProfilerError < StandardError; include CLAide::InformativeError; end
    attr_reader :config, :script_path, :verbose, :xcodebuild_pid, :app_pid, :dtrace_pid

    def initialize(config, verbose = false)
      @config = config
      @verbose = verbose
      script = config.script.dup
      script.prepend(Constants::EXPERIMENTAL) if @config.experimental
      @script_path = Finder.path_for_script(script)
      raise ProfilerError, "This intrument doesn't support --experimental flag".red unless File.exist?(script_path)
    end

    def profile
      return interactive if @config.interactive
      current_directory = Dir.pwd
      Dir.mktmpdir do |tmpdir|
        compile(current_directory, tmpdir)
        Simctl.execute_with_simulator_ready(Constants::DEFAULT_RUNTIME, Constants::DEFAULT_DEVICE) do |device_uuid|
          run_tests(tmpdir, device_uuid)
          find_app_pid
          notify_server
          attach_dtrace(tmpdir)
          wait
        end
        process_dtrace_output(current_directory, tmpdir)
      end
    end

    private

    def interactive()
      find_app_pid
      attach_dtrace('.')
      stream_dtrace_output
    end

    def compile(current_directory, temporary_directory)
      xcodebuild_cmd = %w[xcodebuild]
      xcodebuild_cmd += if config.workspace
                          %W[-workspace #{current_directory}/#{config.workspace}]
                        else
                          %W[-project #{current_directory}/#{config.project}]
                        end
      xcodebuild_cmd += %W[-scheme #{config.scheme}]
      xcodebuild_cmd += %w[-sdk iphonesimulator]
      xcodebuild_cmd += %W[-derivedDataPath #{temporary_directory}/derivedData]
      xcodebuild_cmd += %w[clean build-for-testing]
      cmd = xcodebuild_cmd.join(' ')
      Executor.execute(cmd, verbose)
    end

    def run_tests(temporary_directory, device_uuid)
      xctestrun = Finder.find_xctestrun(temporary_directory)
      xcodebuild_cmd = %w[xcodebuild]
      xcodebuild_cmd += %W[-xctestrun #{xctestrun}]
      xcodebuild_cmd += %W[-destination 'platform=iOS Simulator,id=#{device_uuid}']
      xcodebuild_cmd += %w[test-without-building]
      cmd = xcodebuild_cmd.join(' ')
      @xcodebuild_pid = Executor.execute_async(cmd)
    end

    def find_app_pid
      @app_pid = Executor.timeout(config.process)
    end

    def notify_server
      uri = URI.parse("http://localhost:#{config.server_port}/")
      http = Net::HTTP.new(uri.host, uri.port)
      http.request(Net::HTTP::Get.new(uri.request_uri))
    rescue
      retry
    end

    def attach_dtrace(temporary_directory)
      dtrace_cmd = %w[sudo dtrace]
      dtrace_cmd += %W[-q -s #{script_path}]
      dtrace_cmd += %W[-p #{app_pid}]
      dtrace_cmd += %W[> #{temporary_directory}/#{Constants::DTRACE_OUTPUT}]
      cmd = dtrace_cmd.join(' ')
      @dtrace_pid = Executor.execute_async(cmd)
    end

    def wait
      Process.wait(xcodebuild_pid)
      Process.kill("QUIT", dtrace_pid)
    end

    def process_dtrace_output(current_directory, temporary_directory)
      report = "timeStamp,elapsed,label,responseCode,success\n"
      epoch = Time.now.to_i
      File.readlines("#{temporary_directory}/#{Constants::DTRACE_OUTPUT}").each do |line|
        to_parse = line.strip
        next if to_parse.empty?
        values = to_parse.split(Constants::TRACE_SCRIPT_DELIMITER)
        view_controller = values[0]
        elapsed = values[1].to_f / 1000000
        report += "#{epoch},%.0f,#{view_controller},#{Constants::RESPONSE_CODE},#{Constants::SUCCESS}\n" % elapsed
      end
      File.write("#{current_directory}/#{Constants::JTL_REPORT}", report)
    end

    def stream_dtrace_output
      output_file = Constants::DTRACE_OUTPUT
      FileUtils.rm_rf(output_file) if File.exist? output_file
      touch_cmd = %W[touch "#{output_file}"]
      cmd = touch_cmd.join(' ')
      Executor.execute(cmd, verbose)
      stream = IO.new(IO.sysopen(output_file))
      Logger.log("Started interactive session. #{"Press CTRL+C to finish.".blue}")
      begin
        loop do
          output = stream.gets
          puts output unless output.nil?
        end
      rescue SignalException => e
        raise ProfilerInterruptError, "Interactive session ended. Full output at ./#{output_file}".green
      end
    end
  end
end
