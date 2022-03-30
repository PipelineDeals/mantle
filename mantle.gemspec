# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mantle/version'

Gem::Specification.new do |gem|
  gem.name          = "mantle"
  gem.version       = Mantle::VERSION
  gem.authors       = ["Grant Ammons", "Brandon Hilkert", "Scott Gibson", "Frank Hmeidan"]
  gem.email         = ["gammons@gmail.com", "brandonhilkert@gmail.com", "sevgibson@gmail.com", "frank.hmeidan@gmail.com"]
  gem.description   = %q{Ruby application message bus subscriptions with Sidekiq and Redis Pubsub.}
  gem.summary       = %q{Ruby application message bus subscriptions with Sidekiq and Redis Pubsub.}
  gem.homepage      = "https://github.com/PipelineDeals/mantle"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('redis')
  gem.add_dependency('sidekiq', '~> 5.0')
  gem.add_dependency('uuidtools')

  gem.add_development_dependency('rspec')
  gem.add_development_dependency('pry')
end
