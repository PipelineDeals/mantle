require 'spec_helper'

describe ModelHandler do
  before :each do
    stub_const("HTTParty", double())
    HTTParty.stub(:post).and_return(fake_response)
  end

  let(:handler) { ModelHandler.new }

  context 'person' do
    it "adds to index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "person-2", "version" => 1, "lang" => "en", "fields" => { :id => "2", :name => "Tommy Thompson", :email => "tommy@example.com" }}].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:create:person", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end

    it "updates the index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "person-2", "version" => 1, "lang" => "en", "fields" => { :id => "2", :name => "Tommy Thompson", :email => "tommy@example.com" }}].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:update:person", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end

    it "deletes from index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "delete", "id" => "person-2", "version" => 2 }].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:delete:person", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end
  end

  context 'company' do
    it "adds to index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "company-2", "version" => 1, "lang" => "en", "fields" => { :id => "2", :name => "Tommy Thompson", :email => "tommy@example.com" }}].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:create:company", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end

    it "updates the index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "company-2", "version" => 1, "lang" => "en", "fields" => { :id => "2", :name => "Tommy Thompson", :email => "tommy@example.com" }}].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:update:company", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end

    it "deletes from index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "delete", "id" => "company-2", "version" => 2 }].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:delete:company", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end
  end

  context 'deal' do
    it "adds to index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "deal-2", "version" => 1, "lang" => "en", "fields" => { :id => "2", :name => "Tommy Thompson", :email => "tommy@example.com" }}].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:create:deal", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end

    it "updates the index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "deal-2", "version" => 1, "lang" => "en", "fields" => { :id => "2", :name => "Tommy Thompson", :email => "tommy@example.com" }}].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:update:deal", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end

    it "deletes from index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "delete", "id" => "deal-2", "version" => 2 }].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:delete:deal", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end
  end

  context 'note' do
    it "adds to index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "note-2", "version" => 1, "lang" => "en", "fields" => { :id => "2", :name => "Tommy Thompson", :email => "tommy@example.com" }}].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:create:note", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end

    it "updates the index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "add", "id" => "note-2", "version" => 1, "lang" => "en", "fields" => { :id => "2", :name => "Tommy Thompson", :email => "tommy@example.com" }}].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:update:note", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end

    it "deletes from index" do
      HTTParty.should_receive(:post).with("http://doc-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/documents/batch", { :body => [{ "type" => "delete", "id" => "note-2", "version" => 2 }].to_json, :headers => { "Content-Type" => "application/json"}})

      handler.call("jupiter:delete:note", "{\"id\":\"2\", \"name\":\"Tommy Thompson\",\"email\":\"tommy@example.com\"}")
    end
  end
end