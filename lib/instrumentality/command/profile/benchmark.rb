require 'instrumentality/command'
require 'instrumentality/finder'
require 'instrumentality/profiler'
require 'instrumentality/constants'
require 'ostruct'

module Instrumentality
  class Profile < Command
    class Benchmark < Profile
      def self.options
        shared_options.concat([
          ['--experimental', "Don't use it if you don't know what it does"],
        ]).concat(super)
      end

      self.arguments = shared_arguments.concat([
      ])

      self.summary = <<-DESC
        Runs a benchmark against a specific iOS process. Requires static probes.
      DESC

      def initialize(argv)
        @experimental = argv.flag?('experimental', false)
        super
      end

      def validate!
        super
        validate_shared_arguments!
      end

      def run
        config = OpenStruct.new({'script' => Constants::BENCHMARK_SCRIPT,
                                 'process' => @process,
                                 'workspace' => @workspace,
                                 'project' => @project,
                                 'scheme' => @scheme,
                                 'server_port' => @server_port,
                                 'interactive' => @interactive,
                                 'experimental' => @experimental})
        profiler = Profiler.new(config, @verbose)
        profiler.profile
      end
    end
  end
end
