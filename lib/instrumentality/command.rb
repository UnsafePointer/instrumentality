require 'claide'
require 'instrumentality/version'

module Instrumentality
  class Command < CLAide::Command
    require 'instrumentality/command/benchmark'
    require 'instrumentality/command/file_activity'
    require 'instrumentality/command/generate_header'
    require 'instrumentality/command/custom'

    self.abstract_command = true
    self.command = 'instr'
    self.version = Instrumentality::VERSION
    self.description = <<-DESC
      Command line interface to profiling tools for iOS development
    DESC
  end
end
