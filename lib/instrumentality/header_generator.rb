require 'instrumentality/executor'
require 'instrumentality/finder'
require 'instrumentality/constants'
require 'claide'
require 'colorize'

module Instrumentality
  class HeaderGenerator
    class HeaderGeneratorError < StandardError; include CLAide::InformativeError; end
    attr_reader :instrument, :verbose

    def initialize(instrument, verbose = false)
      @instrument = instrument
      @verbose = verbose
    end

    def generate
      path_for_header = Finder.path_for_header("#{instrument}.d")
      raise HeaderGeneratorError, "Couldn't find header for #{instrument} instrument".red unless File.exist?(path_for_header)
      dtrace_cmd = %w[dtrace]
      dtrace_cmd += %W[-h -s #{path_for_header}]
      cmd = dtrace_cmd.join(' ')
      Executor.execute(cmd, verbose)
    end
  end
end
