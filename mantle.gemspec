# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mantle/version'

Gem::Specification.new do |gem|
  gem.name          = "mantle"
  gem.version       = Mantle::VERSION
  gem.authors       = ["Grant Ammons"]
  gem.email         = ["gammons@gmail.com"]
  gem.description   = %q{mantle is mantling.}
  gem.summary       = %q{you know it!}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('redis')
  gem.add_dependency('redis-namespace')
  gem.add_dependency('sidekiq', '~> 2.0')
  gem.add_dependency('json')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('pry')
end
