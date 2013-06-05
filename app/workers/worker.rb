class Worker
  include Sidekiq::Worker

  def perform(channel, message)
    # Convert message to object
    object = JSON.parse(message)['data']

    "#{get_action(channel).capitalize}Handler".constantize.new(object).run
  end
end
