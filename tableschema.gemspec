# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tableschema/version'

Gem::Specification.new do |spec|
  spec.name          = "tableschema"
  spec.version       = TableSchema::VERSION
  spec.authors       = ["Open Knowledge Foundation"]
  spec.email         = ["info@okfn.org"]

  spec.summary       = "A Ruby library for working with Table Schema. Formerly known as 'jsontableschema'"
  spec.homepage      = "https://github.com/frictionlessdata/tableschema-rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10.0"
  spec.add_development_dependency "webmock", "~> 2.3.0"
  spec.add_development_dependency "coveralls", "~> 0.8.13"
  spec.add_development_dependency "rubocop", "~> 0.49.1"

  spec.add_dependency "json-schema", "~> 2.8.0"
  spec.add_dependency "uuid", "~> 2.3.8"
  spec.add_dependency "tod", "~> 2.1.0"
  spec.add_dependency "activesupport", "~> 5.1.0"
end
