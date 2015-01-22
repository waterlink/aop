# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aop/version'

Gem::Specification.new do |spec|
  spec.name          = "aop"
  spec.version       = Aop::VERSION
  spec.authors       = ["Alex Fedorov"]
  spec.email         = ["waterlink000@gmail.com"]
  spec.summary       = %q{Very thin AOP gem for Ruby}
  spec.description   = %q{Thin and fast framework for Aspect Oriented Programming in Ruby.}
  spec.homepage      = "https://github.com/waterlink/aop"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
