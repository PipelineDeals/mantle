class CreateNonimportWorker < Worker
  sidekiq_options :queue => :create_nonimport
end
