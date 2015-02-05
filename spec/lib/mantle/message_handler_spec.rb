require 'spec_helper'

describe Mantle::MessageHandler do
  describe ".receive" do
    it 'raises with warning about implementation' do
      expect {
        Mantle::MessageHandler.receive("person", "update", {})
      }.to raise_error(Mantle::Error::MissingImplementation)
    end
  end
end

