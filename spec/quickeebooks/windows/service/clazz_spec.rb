require 'spec_helper'

describe "Quickeebooks::Windows::Service::Clazz" do
  before(:all) do
    qb_key = "key"
    qb_secret = "secreet"

    @realm_id = "9991111222"
    @base_uri = "https://qbo.intuit.com/qbo36"
    @oauth_consumer = OAuth::Consumer.new(qb_key, qb_key, {
        :site                 => "https://oauth.intuit.com",
        :request_token_path   => "/oauth/v1/get_request_token",
        :authorize_path       => "/oauth/v1/get_access_token",
        :access_token_path    => "/oauth/v1/get_access_token"
    })
    @oauth = OAuth::AccessToken.new(@oauth_consumer, "blah", "blah")
  end

  describe '#list' do
    it "makes a request for a collection of classes" do
      xml = windowsFixture("classes.xml")
      model = Quickeebooks::Windows::Model::Clazz
      service = Quickeebooks::Windows::Service::Clazz.new
      service.access_token = @oauth
      service.realm_id = @realm_id
      stub_request(:post, service.url_for_resource(model::REST_RESOURCE)).to_return(:status => ["200", "OK"], :body => xml)
      classes = service.list
      classes.entries.count.should == 3
      entry = classes.entries.first
      entry.name.should == "Bugay"
      entry.id.to_i.should == 157
      entry.active?.should == true
    end
  end
end
