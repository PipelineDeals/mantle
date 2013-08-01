require 'mantle'
require 'sidekiq'
require 'sidekiq/cli'
require 'mantle/sidekiq_overrides'

namespace :mantle do
  desc "Runs the listener to listen for changes to things in PipelineDeals"
  task :listen do
    Mantle.setup
    Mantle.run!
  end

  desc "Runs the sidekiq process to process messages locally"
  task :process do
    Sidekiq.options = { concurrency: 25, require: 'mantle/load_workers', queues: ['update'] }
    cli = Sidekiq::CLI.instance
    cli.parse
    cli.run
  end
end
