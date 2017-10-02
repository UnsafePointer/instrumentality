require 'instrumentality/executor'
require 'instrumentality/finder'
require 'instrumentality/constants'

module Instrumentality
  class HeaderGenerator
    attr_reader :instrument, :verbose

    def initialize(instrument, verbose)
      @instrument = instrument
      @verbose = verbose
    end

    def generate
      dtrace_cmd = %w[dtrace]
      dtrace_cmd += %W[-h -s #{Finder.path_for_header(Constants::BENCHMARK_SCRIPT)}]
      cmd = dtrace_cmd.join(' ')
      Executor.execute(cmd, verbose)
    end
  end
end
