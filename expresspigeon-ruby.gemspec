# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'expresspigeon-ruby/version'

Gem::Specification.new do |gem|
  gem.name          = "expresspigeon-ruby"
  gem.version       = Expresspigeon::API::VERSION
  gem.authors       = ["ipolevoy"]
  gem.email         = ["igor@expresspigeon.com"]
  gem.description   = %q{ExpressPigeon Ruby API for sending transactional messages, manipulating lists, contacts and more}
  gem.summary       = %q{ExpressPigeon API Ruby Wrapper}
  gem.homepage      = "https://github.com/expresspigeon/expresspigeon-ruby"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'rest-client', '~> 1.8.0'

  gem.add_development_dependency "rspec", "~> 2.6"
end
