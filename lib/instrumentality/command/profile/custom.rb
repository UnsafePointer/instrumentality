require 'instrumentality/command'
require 'instrumentality/finder'
require 'instrumentality/profiler'
require 'instrumentality/constants'
require 'ostruct'

module Instrumentality
  class Profile < Command
    class Custom < Profile
      def self.options
        shared_options.concat([
        ]).concat(super)
      end

      self.arguments = shared_arguments.concat([
        CLAide::Argument.new("script", true),
      ])

      self.summary = <<-DESC
        Runs a DTrace script against a specific iOS process.
      DESC

      def initialize(argv)
        super
        @script = argv.shift_argument
      end

      def validate!
        super
        validate_shared_arguments!
      end

      def run
        config = OpenStruct.new({'script' => @script,
                                 'process' => @process,
                                 'workspace' => @workspace,
                                 'project' => @project,
                                 'scheme' => @scheme,
                                 'server_port' => @server_port,
                                 'interactive' => @interactive,
                                 'experimental' => false})
        profiler = Profiler.new(config, @verbose)
        profiler.profile
      end
    end
  end
end
