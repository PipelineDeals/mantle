require 'spec_helper'

describe Mantle::MessageHandlers do
  describe '#receive_message' do
    context 'given a channel that exists' do
      it 'delegates the channel and message to the matching handlers' do
        class_double('FakeHandler').as_stubbed_const

        FakeHandler.singleton_class.send :attr_accessor, :channel, :message
        FakeHandler.define_singleton_method :receive do |channel, message|
          self.channel, self.message = channel, message
        end

        Mantle::MessageHandlers.new('a_channel' => 'FakeHandler').receive_message(
          'a_channel', 'a_message'
        )

        expect(FakeHandler).to have_attributes(
          channel: 'a_channel', message: 'a_message'
        )
      end
    end

    context 'given a channel that does not exist' do
      it 'raises an error' do
        expect {
          Mantle::MessageHandlers.new(
            'existing_channel' => '',
            'existing_channel2' => ''
          ).receive_message 'missing_channel', 'foo'
        }.to raise_error(
          Mantle::Error::ChannelNotFound,
          "'missing_channel' not found. Existing channels: existing_channel, existing_channel2"
        )
      end
    end
  end
end
