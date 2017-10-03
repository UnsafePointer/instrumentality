require 'instrumentality/command'
require 'instrumentality/finder'
require 'instrumentality/benchmarker'
require 'instrumentality/constants'
require 'ostruct'

module Instrumentality
  class Benchmark < Command
    def self.options
      [
        ['--workspace=path/to/name.xcworkspace', 'If not set, Instr will try to find one'],
        ['--project=path/to/name.xcodeproj', 'If not set and workspace search failed, Instr will try to find one'],
        ['--scheme=name', 'If not set, Instr will use the process name'],
        ['--server-port=port_number', 'If not set, Instr will use 8080'],
      ].concat(super)
    end

    self.arguments = [
      CLAide::Argument.new("process", true),
    ]

    self.summary = <<-DESC
      Runs a benchmark against a specific iOS process. Requires static probes.
    DESC

    def initialize(argv)
      @process = argv.shift_argument
      @workspace = argv.option('workspace') || Finder.find_workspace
      @project = argv.option('project')
      @project ||= Finder.find_project if @workspace.nil?
      @scheme = argv.option('scheme') || @process
      @server_port = argv.option('server-port') || Constants::DEFAULT_SERVER_PORT
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
                               'scheme' => @scheme,
                               'server_port' => @server_port})
      profiler = Benchmarker.new(config, @verbose)
      profiler.profile
    end
  end
end
