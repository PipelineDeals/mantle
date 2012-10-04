class AmazonWorker
  include Sidekiq::Worker
  include Formattable

  def perform(channel, message)
    # Convert message to object
    object = JSON.parse(message)['data']

    # Prepare model and object id
    model = channel.split(':')[2]
    if %w[contact lead].include? model
      model = 'person'
    end
    id = "#{model}_#{object['id']}"

    fields = fields_for_document object, model

    # Parse channel for action
    # Expects e.g. jupiter:create:person
    action = channel.split(':')[1]

    version = Time.parse(object['updated_at']).to_i

    # Send to CloudSearch
    case action
    when 'create'
      # puts 'CREATING'
      $asari.add_item(id, version, fields)
    when 'update'
      # puts 'UPDATING'
      $asari.update_item(id, version, fields)
    when 'destroy'
      # puts 'DELETING'
      $asari.remove_item(id, Time.now.to_i)
    end

    # Save timestamp to database
    # TODO Not thread-safe...does it matter?
    Settings.last_success = Time.now.to_i
  end
end