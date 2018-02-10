require 'instrumentality/constants'

module Instrumentality
  class Logger
    def self.log(message)
      puts "#{Constants::OUTPUT_PREFIX} #{message}"
    end
  end
end
