class DeleteWorker < Worker
  sidekiq_options :queue => :delete
end
