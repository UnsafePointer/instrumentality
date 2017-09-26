require 'instrumentality/constants'
require 'claide'
require 'colorize'
require 'timeout'

module Instrumentality
  class Executor
    class ExecutorError < StandardError; include CLAide::InformativeError; end

    def self.execute(cmd, verbose)
      puts "#{Constants::OUTPUT_PREFIX} Executing command: #{cmd}"
      if verbose
        system(cmd)
      else
        `#{cmd}`
      end
      status = $?.exitstatus
      raise ExecutorError, "Previous command execution failed with status: #{status}".red if status != 0
    end

    def self.execute_async(cmd)
      spawn("#{cmd}").tap do |pid|
        puts "#{Constants::OUTPUT_PREFIX} Spawned process (PID: #{pid}) from command: #{cmd}"
      end
    end

    def self.timeout(process, seconds = Constants::TIMEOUT)
      pid = ""
      Timeout.timeout(seconds) do
        loop do
          pid = `ps aux | grep #{process} | grep -v grep | awk '{print $2}'`.delete("\n")
          break if pid != ""
        end
      end
      pid.tap do |pid|
        puts "#{Constants::OUTPUT_PREFIX} Found process #{process} with PID: #{pid}"
      end
    end
  end
end
