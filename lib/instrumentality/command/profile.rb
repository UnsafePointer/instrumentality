require 'instrumentality/command'

module Instrumentality
  class Profile < Command
    def self.options
      [
      ].concat(super)
    end

    self.summary = <<-DESC
      Attach a profiler to a specific iOS process
    DESC

    def initialize(argv)
      super
    end

    def validate!
      super
    end

    def run

    end
  end
end
