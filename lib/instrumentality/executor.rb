require 'instrumentality/logger'
require 'claide'
require 'colorize'
require 'timeout'

module Instrumentality
  class Executor
    class ExecutorError < StandardError; include CLAide::InformativeError; end

    def self.execute(cmd, verbose = false)
      Logger.log("Executing command: #{cmd}")
      if verbose
        system(cmd)
      else
        `#{cmd}`
      end
      status = $?.exitstatus
      raise ExecutorError, "Previous command execution failed with status: #{status}".red if status != 0
    end

    def self.execute_async(cmd)
      Process.spawn("#{cmd}").tap do |pid|
        Logger.log("Spawned process (PID: #{pid}) from command: #{cmd}")
      end
    end

    def self.timeout(process, seconds = Constants::TIMEOUT)
      pid = ""
      begin
        Timeout.timeout(seconds) do
          loop do
            pid = `ps aux | grep #{process}.app | grep -v grep | awk '{print $2}'`.strip
            break if pid != ""
          end
        end
      rescue Timeout::Error
        raise ExecutorError, "Timeout while trying to find #{process} process".red
      end
      pid.tap do |pid|
        Logger.log("Found process #{process} with PID: #{pid}")
      end
    end
  end
end
