module Mantle
  class MessageRouter
    def initialize(channel, message)
      @channel, @message = channel, message
    end

    def route!
      action = @channel.split(':')[1] # TODO Repetitive?

      klass = case action
      when 'create'
        object = JSON.parse(@message)['data']
        if object['import_id']
          CreateImportWorker
        else
          CreateNonimportWorker
        end
      when 'update'
        UpdateWorker
      when 'destroy'
        DeleteWorker
      end
      klass.perform_async(@channel, @message)
    end
  end
end
