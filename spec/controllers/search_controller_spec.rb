require 'spec_helper'

describe SearchController do
  before :each do
    stub_const("HTTParty", double())
    HTTParty.stub(:get).and_return(fake_response)
  end

  it "searches" do
    HTTParty.should_receive(:get).with("http://search-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=yeah&size=10")

    get :index, { q: 'yeah' }
  end

  it "supports pagination" do
    HTTParty.should_receive(:get).with("http://search-search-domain-goes-here.us-east-1.cloudsearch.amazonaws.com/2011-02-01/search?q=yeah&size=20&start=40")

    get :index, { q: 'yeah', per: 20, page: 3 }
  end
end