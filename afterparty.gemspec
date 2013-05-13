# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'afterparty/version'

Gem::Specification.new do |spec|
  spec.name          = "afterparty"
  spec.version       = Afterparty::VERSION
  spec.authors       = ["Hank Stoever"]
  spec.email         = ["hstove@gmail.com"]
  spec.description   = %q{Rails 4 compatible queue with support for executing jobs later.}
  spec.summary       = %q{Rails 4 compatible queue with support for executing jobs later.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", '~> 4'
  spec.add_dependency "redis"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
