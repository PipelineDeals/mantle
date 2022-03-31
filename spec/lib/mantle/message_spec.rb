require 'spec_helper'

describe Mantle::Message do
  describe "#publish" do
    it "sends message to message bus" do
      bus = double("message bus")
      catch_up = double("catch up")
      channel = "create:person"
      message = { id: 1 }
      actual_message = message.merge(__MANTLE__: { sent_at: instance_of(Time) })

      mantle_message = Mantle::Message.new(channel)
      mantle_message.message_bus = bus
      mantle_message.catch_up = catch_up

      allow(bus).to receive(:publish)
      allow(catch_up).to receive(:add_message)

      mantle_message.publish(message: message)

      expect(bus).to have_received(:publish).with(channel, message)
      expect(catch_up).to have_received(:add_message).with(channel, message)
    end

    it "published message includes message_source" do
      Mantle.configure { |config| config.whoami = 'SantaClaus' }
      bus = double("message bus")
      catch_up = double("catch up")
      channel = "create:person"
      message = { id: 1 }
      actual_message = message.merge(__MANTLE__: { sent_at: instance_of(Time), message_source: 'SantaClaus' })

      mantle_message = Mantle::Message.new(channel)
      mantle_message.message_bus = bus
      mantle_message.catch_up = catch_up

      allow(bus).to receive(:publish)
      allow(catch_up).to receive(:add_message)

      mantle_message.publish(message: message)

      expect(bus).to have_received(:publish).with(channel, actual_message)
      expect(catch_up).to have_received(:add_message).with(channel, actual_message)
    end

    it "allows external payload store" do
      Mantle.configure do |config|
        config.whoami = 'SantaClaus'
        config.external_store = [ :redis, redis: Redis.new ] # or :active_record?
      end
      bus = double("message bus")
      catch_up = double("catch up")
      channel = "create:person"
      message = { id: 1 }
      actual_message = message.merge(__MANTLE__: { sent_at: instance_of(Time), message_source: 'SantaClaus', uuid: instance_of(String) })

      payload = { some: :really, huge: [ { payload: "containing", misc: "stuff" } ] }

      mantle_message = Mantle::Message.new(channel)
      mantle_message.message_bus = bus
      mantle_message.catch_up = catch_up

      allow(bus).to receive(:publish)
      allow(catch_up).to receive(:add_message)

      mantle_message.publish(message: message, payload: payload)

      expect(bus).to have_received(:publish).with(channel, actual_message)
      expect(catch_up).to have_received(:add_message).with(channel, actual_message)
    end
  end
end
