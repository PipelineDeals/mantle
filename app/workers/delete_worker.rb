class DeleteWorker < AmazonWorker
  sidekiq_options :queue => :delete
end