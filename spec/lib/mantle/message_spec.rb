require 'spec_helper'

describe Mantle::Message do
  describe "#publish" do
    it "sends message to message bus" do
      bus = double("message bus")
      catch_up = double("catch up")
      channel = "create:person"
      message = { id: 1 }

      mantle_message = Mantle::Message.new(channel)
      mantle_message.message_bus = bus
      mantle_message.catch_up = catch_up

      expect(bus).to receive(:publish).with(channel, message)
      expect(catch_up).to receive(:add_message).with(channel, message)

      mantle_message.publish(message)
    end

    it "published message includes message_source" do
      Mantle.configure { |config| config.whoami = 'SantaClaus' }
      bus = double("message bus")
      catch_up = double("catch up")
      channel = "create:person"
      message = { id: 1 }
      actual_message = message.merge(message_source: 'SantaClaus')

      mantle_message = Mantle::Message.new(channel)
      mantle_message.message_bus = bus
      mantle_message.catch_up = catch_up

      expect(bus).to receive(:publish).with(channel, actual_message)
      expect(catch_up).to receive(:add_message).with(channel, actual_message)

      mantle_message.publish(message)
    end
  end
end
