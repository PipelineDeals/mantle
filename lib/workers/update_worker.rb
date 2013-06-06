module Mantle
  class UpdateWorker < Worker
    sidekiq_options :queue => :update
  end
end
