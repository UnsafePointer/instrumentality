# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "instrumentality/version"

Gem::Specification.new do |spec|
  spec.name          = "instrumentality"
  spec.version       = Instrumentality::VERSION
  spec.authors       = ["Renzo Crisóstomo"]
  spec.email         = ["renzo.crisostomo@here.com"]

  spec.summary       = %q{Command line interface to profiling tools for iOS development}
  spec.description   = %q{Command line interface to profiling tools for iOS development}
  spec.homepage      = "https://github.com/Ruenzuo/instrumentality"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = ["instrumentality", "instr"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'claide', '~> 1.0.2'
  spec.add_runtime_dependency 'colorize', '~> 0.8.1'
  spec.add_runtime_dependency 'simctl', '~> 1.6.2'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-byebug", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "coveralls", "~> 0.7.0"
end
