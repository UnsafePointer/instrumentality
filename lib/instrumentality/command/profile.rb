require 'instrumentality/command'

module Instrumentality
  class Profile < Command
    self.abstract_command = true

    self.summary = "Run instruments"

    #-----#

    def initialize(argv)
      @process = argv.shift_argument
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
    end

    def validate_shared_arguments!
      help! 'A process name is required' unless @process
      return if @interactive
      help! 'Xcode workspace or project files not found' if @workspace.nil? && @project.nil?
    end

    def self.shared_arguments
      [
        CLAide::Argument.new("process", true),
      ]
    end

    def self.shared_options
      [
        ['--workspace=path/to/name.xcworkspace', 'If not set, Instr will try to find one'],
        ['--project=path/to/name.xcodeproj', 'If not set and workspace search failed, Instr will try to find one'],
        ['--scheme=name', 'If not set, Instr will use the process name'],
        ['--server-port=port_number', 'If not set, Instr will use 8080'],
        ['--interactive', 'If set, Instr will not attempt to run an Xcode scheme, but instead attach DTrace directly'],
      ]
    end
  end
end

