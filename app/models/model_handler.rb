class ModelHandler
  def call(channel, message)
    AmazonWorker.perform_async(channel, message)
  end
end