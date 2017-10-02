require 'instrumentality/command'
require 'instrumentality/finder'
require 'instrumentality/benchmarker'
require 'ostruct'

module Instrumentality
  class Benchmark < Command
    def self.options
      [
        ['--workspace=path/to/name.xcworkspace', 'If not set, Scania will try to find one'],
        ['--project=path/to/name.xcodeproj', 'If not set and workspace search failed, Scania will try to find one'],
        ['--scheme=name', 'If not set, Scania will use the process name'],
      ].concat(super)
    end

    self.arguments = [
      CLAide::Argument.new("process", true),
    ]

    self.summary = <<-DESC
      Run a benchmark to a specific iOS process. Requires static probes.
    DESC

    def initialize(argv)
      @process = argv.shift_argument
      @workspace = argv.option('workspace') || Finder.find_workspace
      @project = argv.option('project')
      @project ||= Finder.find_project if @workspace.nil?
      @scheme = argv.option('scheme') || @process
      super
    end

    def validate!
      super

      help! 'A process name is required' unless @process
      help! 'Xcode workspace or project files not found' if @workspace.nil? && @project.nil?
    end

    def run
      config = OpenStruct.new({'process' => @process,
                               'workspace' => @workspace,
                               'project' => @project,
                               'scheme' => @scheme})
      profiler = Benchmarker.new(config, @verbose)
      profiler.profile
    end
  end
end
