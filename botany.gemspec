# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'botany/version'

Gem::Specification.new do |spec|
  spec.name          = "botany"
  spec.version       = Botany::VERSION
  spec.authors       = ["Chris Hoffman"]
  spec.email         = ["choffman@optoro.com"]
  spec.description   = "Helps you define conditions, rules and responses and build complex decision trees out of them."
  spec.summary       = "Abstract Classification Engine"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
