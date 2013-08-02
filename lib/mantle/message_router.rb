module Mantle
  class MessageRouter
    UnknownAction = Class.new(StandardError)

    def initialize(channel, message)
      @channel = channel
      @message = message
    end

    def route!
      return unless @message
      action = @channel.split(':')[0]
      klass = get_worker_from_action(action)

      Mantle.logger.info("Routing message ID: #{parse(@message)['id']} from #{@channel} to #{klass}")
      Mantle.logger.debug(parse(@message))
      klass.perform_async(@channel, parse(@message))
    end

    private

    def get_worker_from_action(action)
      case action
      when 'create'
        object = parse(@message)['data']
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
        raise UnknownAction
      end
    end

    def parse(json)
      JSON.parse(json)
    end
  end
end
