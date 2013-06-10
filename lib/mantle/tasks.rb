require 'sidekiq'
require 'sidekiq/cli'
require 'mantle/sidekiq_overrides'
namespace :mantle do
  desc "Runs the listener to listen for changes to things in PipelineDeals"
  task :listen do
    Mantle.run!
  end

  desc "Runs the sidekiq process to process messages locally"
  task :process do
    Sidekiq.options = {concurrency: 1, require: 'mantle/load_workers', queues: %w(create_nonimport create_import update delete) }
    cli = Sidekiq::CLI.instance
    cli.parse
    cli.run
  end
end
