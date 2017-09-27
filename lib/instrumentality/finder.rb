module Instrumentality
  class Finder
    def self.find_workspace
      find('*.xcworkspace', 1).first
    end

    def self.find_project
      find('*.xcodeproj', 1).first
    end

    def self.find_xctestrun
      find('*.xctestrun').first
    end

    def self.path_for_script(name)
      File.expand_path("../scripts/#{name}", __FILE__)
    end

    def self.find(name, depth = 0, location = '.')
      cmd = %W[find #{location} -name '#{name}']
      cmd += %W[-maxdepth #{depth}] if depth > 0
      `#{cmd.join(' ')}`.split("\n")
    end

    private_class_method :find
  end
end