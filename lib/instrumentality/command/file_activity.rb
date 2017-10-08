require 'instrumentality/command'
require 'instrumentality/finder'
require 'instrumentality/profiler'
require 'instrumentality/constants'
require 'ostruct'

module Instrumentality
  class FileActivity < Command
    def self.options
      [
        ['--workspace=path/to/name.xcworkspace', 'If not set, Instr will try to find one'],
        ['--project=path/to/name.xcodeproj', 'If not set and workspace search failed, Instr will try to find one'],
        ['--scheme=name', 'If not set, Instr will use the process name'],
        ['--server-port=port_number', 'If not set, Instr will use 8080'],
        ['--interactive', 'If set, Instr will not attempt to run an Xcode scheme, but instead attach DTrace directly'],
        ['--experimental', "Don't use it if you don't know what it does"],
      ].concat(super)
    end

    self.arguments = [
      CLAide::Argument.new("process", true),
    ]

    self.summary = <<-DESC
      Prints files opened by a specific iOS process.
    DESC

    def initialize(argv)
      @process = argv.shift_argument
      @workspace = argv.option('workspace') || Finder.find_workspace
      @project = argv.option('project')
      @project ||= Finder.find_project if @workspace.nil?
      @scheme = argv.option('scheme') || @process
      @server_port = argv.option('server-port') || Constants::DEFAULT_SERVER_PORT
      @interactive = argv.flag?('interactive', false)
      @experimental = argv.flag?('experimental', false)
      super
    end

    def validate!
      super

      help! 'A process name is required' unless @process
      return if @interactive
      help! 'Xcode workspace or project files not found' if @workspace.nil? && @project.nil?
    end

    def run
      config = OpenStruct.new({'script' => Constants::FILE_ACTIVITY_SCRIPT,
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
