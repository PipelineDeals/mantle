namespace :mantle do
  desc "Runs the listener to listen for changes to things in PipelineDeals"
  task :listen do
    Mantle.run!
  end

  desc "Runs the sidekiq process to process messages locally"
  task :process do
    Sidekiq.options = {require: 'mantle/workers'}
    cli = Sidekiq::CLI.instance
    cli.parse
    cli.run
  end
end
