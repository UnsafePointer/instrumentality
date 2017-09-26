require 'instrumentality/executor'
require 'instrumentality/finder'

module Instrumentality
  class Profiler
    attr_reader :config, :verbose, :xcodebuild_pid, :app_pid, :dtrace_pid

    def initialize(config, verbose)
      @config = config
      @verbose = verbose
    end

    def profile
      current_directory = Dir.pwd
      Dir.mktmpdir do |dir|
        compile(current_directory, dir)
        run_tests(dir)
        find_app_pid
        attach_dtrace
        wait
      end
    end

    private

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

    def run_tests(temporary_directory)
      xctestrun = Finder.find_xctestrun
      xcodebuild_cmd = %w[xcodebuild]
      xcodebuild_cmd += %W[-xctestrun #{xctestrun}]
      xcodebuild_cmd += %w[-destination 'platform=iOS Simulator,name=iPhone 6,OS=10.3.1']
      xcodebuild_cmd += %w[test-without-building]
      cmd = xcodebuild_cmd.join(' ')
      @xcodebuild_pid = Executor.execute_async(cmd)
    end

    def find_app_pid
      @app_pid = Executor.timeout(config.process)
    end

    def attach_dtrace
      dtrace_cmd = %w[sudo dtrace]
      dtrace_cmd += %W[-q -s #{Finder.path_for_script("trace.d")}]
      dtrace_cmd += %W[-p #{app_pid}]
      dtrace_cmd += %w[> dtrace_output]
      cmd = dtrace_cmd.join(' ')
      @dtrace_pid = Executor.execute_async(cmd)
    end

    def wait
      Process.wait(xcodebuild_pid)
      Process.kill("QUIT", dtrace_pid)
    end
  end
end
