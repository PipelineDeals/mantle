class CreateImportWorker < AmazonWorker
  sidekiq_options :queue => :create_import
end