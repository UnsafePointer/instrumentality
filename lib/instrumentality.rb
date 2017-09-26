require 'instrumentality/version'
require 'instrumentality/command'
require 'claide'

module Instrumentality
  def self.run
    Command.run(ARGV)
  end
end
