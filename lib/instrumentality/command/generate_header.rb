require 'instrumentality/command'
require 'instrumentality/header_generator'

module Instrumentality
  class GenerateHeader < Command
    def self.options
      [
      ].concat(super)
    end

    self.arguments = [
      CLAide::Argument.new("instrument", true),
    ]

    self.summary = <<-DESC
      Generates Objective-C header for instrument.
    DESC

    def initialize(argv)
      @instrument = argv.shift_argument
      super
    end

    def validate!
      super

      help! 'An instrument name is required' unless @instrument
    end

    def run
      header_generator = HeaderGenerator.new(@instrument, @verbose)
      header_generator.generate
    end
  end
end
