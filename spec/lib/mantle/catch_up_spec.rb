require 'spec_helper'

describe Mantle::CatchUp do
  let(:handler) { Mantle::CatchUp.new }
  let(:redis) { handler.redis }

  before :each do
    Mantle.logger.level = Logger::WARN
    Mantle.configuration.message_bus_redis.flushdb
  end

  after :each do
    Mantle.configuration.message_bus_redis.flushdb
  end

  describe "#add_message" do
    it "adds message to redis that expires in 6 hours" do
      channel = "person:update"
      message = { id: 1 }
      json_message = JSON.generate(message)

      catch_up = Mantle::CatchUp.new
      catch_up.add_message(channel, message)

      json_payload = redis.zrange(catch_up.key, 0, -1).first
      channel, message = catch_up.deserialize_payload(json_payload)

      expect(channel).to eq(channel)
      expect(message).to eq(message)
    end

    it "returns time for message" do
      catch_up = Mantle::CatchUp.new
      time = catch_up.add_message("person:update", { id: 1 }, 1234.56)
      expect(time).to eq(1234.56)
    end
  end

  describe "#enqueue_clear_if_ready" do
    it "enqueues clear job if it was done more than 5 min. ago" do
      time = Time.now.utc.to_f - (6 * 60.0)
      Mantle::LocalRedis.set_catch_up_cleanup(time)

      expect {
        Mantle::CatchUp.new.enqueue_clear_if_ready
      }.to change(Mantle::Workers::CatchUpCleanupWorker.jobs, :size).by(1)
    end

    it "enqueues clear job if no last cleanup time has been recorded" do
      Mantle::LocalRedis.set_catch_up_cleanup(nil)

      expect {
        Mantle::CatchUp.new.enqueue_clear_if_ready
      }.to change(Mantle::Workers::CatchUpCleanupWorker.jobs, :size).by(1)
    end

    it "doesn't enqueue a clear job if enough time hasn't passed" do
      time = Time.now.utc.to_f - (4 * 60.0)
      Mantle::LocalRedis.set_catch_up_cleanup(time)

      expect {
        Mantle::CatchUp.new.enqueue_clear_if_ready
      }.to_not change(Mantle::Workers::CatchUpCleanupWorker.jobs, :size)
    end
  end

  describe "#clear_expired" do
    it "clears expired entries from the catch up list" do
      cu = Mantle::CatchUp.new
      cu.add_message("person:update", { id: 1 }, cu.hours_ago_in_seconds(8))
      cu.add_message("deal:update", { id: 2 }, cu.hours_ago_in_seconds(7))
      cu.add_message("company:update", { id: 3 }, cu.hours_ago_in_seconds(5))

      cu.clear_expired

      expect(redis.zcount(cu.key, 0, 'inf')).to eq(1)

      json_payload = redis.zrange(cu.key, 0, -1).first
      channel, message = cu.deserialize_payload(json_payload)

      expect(channel).to eq("company:update")
    end
  end

  describe "catch_up" do
    it "raises when redis connection is missing" do
      cu = Mantle::CatchUp.new
      cu.redis = nil

      expect {
        cu.catch_up
      }.to raise_error(Mantle::Error::MissingRedisConnection)
    end

    it "skips if no successfully processed time has been recorded" do
      cu = Mantle::CatchUp.new

      cu.add_message("person:update", { id: 1 })
      cu.add_message("deal:update", { id: 2 })
      cu.add_message("company:update", { id: 3 })
      time = cu.add_message("user:update", { id: 3 })

      expect(cu).to_not receive(:route_messages)

      cu.catch_up
    end

    it "doesn't process anything when system is up to date no last successfully processed message time has been record" do
      cu = Mantle::CatchUp.new

      cu.add_message("person:update", { id: 1 })
      cu.add_message("deal:update", { id: 2 })
      cu.add_message("company:update", { id: 3 })
      time = cu.add_message("user:update", { id: 3 })

      Mantle::LocalRedis.set_message_successfully_received

      expect(cu).to_not receive(:route_messages)

      cu.catch_up
    end

    it "handles all messages that need catch up" do
      cu = Mantle::CatchUp.new

      cu.add_message("person:update", { id: 1 })
      cu.add_message("deal:update", { id: 2 })
      cu.add_message("company:update", { id: 3 })

      Mantle::LocalRedis.set_message_successfully_received

      time = cu.add_message("user:update", { id: 3 })

      expect(cu).to receive(:route_messages).with(
        [["{\"channel\":\"user:update\",\"message\":{\"id\":3}}", time]]
      )

      cu.catch_up
    end
  end

  describe "#last_success_time" do
    it "returns time of last successfully process message"do
      expect(Mantle::LocalRedis).to receive(:last_message_successfully_received_at)
      Mantle::CatchUp.new.last_success_time
    end
  end

  describe "#route_messages" do
    it "process messages if listening to that channel" do
      p =[["{\"channel\":\"user:update\",\"message\":{\"id\":3}}", 1423336645.314663]]
      cu = Mantle::CatchUp.new
      cu.message_bus_channels = ["user:update"]

      expect(Mantle::MessageRouter).to receive(:new).with(
        "user:update", { "id" => 3 }
      ).and_return(double("router", route: true))

      cu.route_messages(p)
    end

    it "skips messages on channels not subscribed" do
      p =[["{\"channel\":\"user:update\",\"message\":{\"id\":3}}", 1423336645.314663]]
      cu = Mantle::CatchUp.new
      cu.message_bus_channels = ["user:create"]

      expect(Mantle::MessageRouter).to_not receive(:new)

      cu.route_messages(p)
    end
  end

end

