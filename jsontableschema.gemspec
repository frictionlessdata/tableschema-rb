# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsontableschema/version'

Gem::Specification.new do |spec|
  spec.name          = "jsontableschema"
  spec.version       = JsonTableSchema::VERSION
  spec.authors       = ["pezholio"]
  spec.email         = ["pezholio@gmail.com"]

  spec.summary       = "A Ruby library for working with JSON Table Schema"
  spec.homepage      = "https://github.com/theodi/jsontableschema.rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.post_install_message = <<-MESSAGE
  WARNING:   The 'jsontableschema' gem has been deprecated and will be replaced by the gem 'tableschema'.
             See: https://github.com/frictionlessdata/tableschema-rb
  MESSAGE

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10.0"
  spec.add_development_dependency "webmock", "~> 2.3.0"
  spec.add_development_dependency "coveralls", "~> 0.8.13"

  spec.add_dependency "json-schema", "~> 2.6.0"
  spec.add_dependency "uuid", "~> 2.3.8"
  spec.add_dependency "currencies", "~> 0.4.2"
  spec.add_dependency "tod", "~> 2.1.0"
end
