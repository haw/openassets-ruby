# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openassets/version'

Gem::Specification.new do |spec|
  spec.name          = "openassets-ruby"
  spec.version       = OpenAssets::VERSION
  spec.authors       = ["azuchi"]
  spec.email         = ["azuchi@haw.co.jp"]

  spec.summary       = %q{The implementation of the Open Assets Protocol for Ruby.}
  spec.description   = %q{The implementation of the Open Assets Protocol for Ruby.}
  spec.homepage      = "https://github.com/haw-itn/openassets-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "bitcoin-ruby", "~> 0.0.11"
  spec.add_runtime_dependency "ffi", "~>1.9.8"
  spec.add_runtime_dependency "rest-client", "~>1.8.0"
  spec.add_runtime_dependency "httpclient"
  spec.add_runtime_dependency "sqlite3"
  spec.add_runtime_dependency "leb128", '~> 1.0.0'
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "travis"

end
