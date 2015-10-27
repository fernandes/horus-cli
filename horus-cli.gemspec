# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'horus/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "horus-cli"
  spec.version       = Horus::Cli::VERSION
  spec.authors       = ["George Moura"]
  spec.email         = ["gwmoura@gmail.com"]

  spec.summary       = %q{hotus-cli is a command line tool for use Horus API}
  spec.description   = %q{With horus-cli command line you can to use Horus API to list, create and update informations about your clients or your profile}
  spec.homepage      = "http://github.com/zertico/horus-cli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "json_api_client"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
end
