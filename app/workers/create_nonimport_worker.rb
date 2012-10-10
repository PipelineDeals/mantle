class CreateNonimportWorker < AmazonWorker
  sidekiq_options :queue => :create_nonimport
end