require 'instrumentality/command'
require 'instrumentality/finder'
require 'instrumentality/profiler'
require 'instrumentality/constants'
require 'ostruct'

module Instrumentality
  class Custom < Command
    def self.options
      [
        ['--workspace=path/to/name.xcworkspace', 'If not set, Instr will try to find one'],
        ['--project=path/to/name.xcodeproj', 'If not set and workspace search failed, Instr will try to find one'],
        ['--scheme=name', 'If not set, Instr will use the process name'],
        ['--server-port=port_number', 'If not set, Instr will use 8080'],
        ['--interactive', 'If set, Instr will not attempt to run an Xcode scheme, but instead attach DTrace directly'],
      ].concat(super)
    end

    self.arguments = [
      CLAide::Argument.new("process", true),
      CLAide::Argument.new("script", true),
    ]

    self.summary = <<-DESC
      Runs a DTrace script against a specific iOS process.
    DESC

    def initialize(argv)
      @process = argv.shift_argument
      @script = argv.shift_argument
      @workspace = argv.option('workspace') || Finder.find_workspace
      @project = argv.option('project')
      @project ||= Finder.find_project if @workspace.nil?
      @scheme = argv.option('scheme') || @process
      @server_port = argv.option('server-port') || Constants::DEFAULT_SERVER_PORT
      @interactive = argv.flag?('interactive', false)
      super
    end

    def validate!
      super

      help! 'A process name is required' unless @process
      help! 'A valid script path is required' unless File.exist?(@script)
      return if @interactive
      help! 'Xcode workspace or project files not found' if @workspace.nil? && @project.nil?
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
