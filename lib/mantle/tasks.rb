namespace :mantle do
  desc "Runs the listener to listen for changes to things in PipelineDeals"
  task :listen do
    Mantle.run!
  end
end
