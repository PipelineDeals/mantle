class UpdateWorker < AmazonWorker
  sidekiq_options :queue => :update
end