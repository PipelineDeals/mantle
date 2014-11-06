require 'spec_helper'

describe Mantle::MessageBus do
  let(:channels) { ["dingle:create:person", "dingle:update:person", "dingle:delete:person", "dingle:create:contact",
                    "dingle:update:contact", "dingle:delete:contact", "dingle:create:lead", "dingle:update:lead",
                    "dingle:delete:lead", "dingle:create:company", "dingle:update:company", "dingle:delete:company",
                    "dingle:create:deal", "dingle:update:deal", "dingle:delete:deal", "dingle:create:note",
                    "dingle:update:note", "dingle:delete:note", "dingle:create:comment", "dingle:update:comment",
                    "dingle:delete:comment"] }
  let(:listener) { Mantle::MessageBus.new(double("redis"), channels)  }

  describe "catchup" do
    it "delegates to the catch up handler" do
      expect_any_instance_of(Mantle::CatchUpHandler).to receive(:catch_up!)
      listener.catch_up
    end
  end
end
