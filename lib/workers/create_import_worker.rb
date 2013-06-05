class CreateImportWorker < Worker
  sidekiq_options :queue => :create_import
end
