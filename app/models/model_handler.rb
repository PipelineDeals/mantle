class ModelHandler
  def call(channel, message)
    # Convert message to object
    object = JSON.parse(message)

    # Prepare model and object id
    model = channel.split(':')[2]
    id = "#{model}-#{object['id']}"

    # Parse channel for action
    # Expects e.g. jupiter:create:person
    action = channel.split(':')[1]

    # Send to CloudSearch
    case action
    when 'create'
      $asari.add_item(id, object)
    when 'update'
      $asari.update_item(id, object)
    when 'delete'
      $asari.remove_item(id)
    end
  end
end