class ModelHandler
  def call(channel, message)
    action = channel.split(':')[1] # TODO Repetitive?

    case action
    when 'create'
      object = JSON.parse(message)['data']
      if object['import_id']
        CreateImportWorker.perform_async(channel, message)
      else
        CreateNonimportWorker.perform_async(channel, message)
      end
    when 'update'
      UpdateWorker.perform_async(channel, message)
    when 'destroy'
      DeleteWorker.perform_async(channel, message)
    end
  end
end
