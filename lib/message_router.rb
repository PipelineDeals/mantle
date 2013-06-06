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
      else
        raise ArgumentError, "Unknown action #{action}"
      end
      klass.perform_async(@channel, JSON.parse(@message))
    end
  end
end
