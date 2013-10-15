require 'spec_helper'

describe "Quickeebooks::Online::Service::CompanyMetaData" do
  before(:all) do
    qb_key = "key"
    qb_secret = "secreet"

    @realm_id = "9991111222"
    @oauth_consumer = OAuth::Consumer.new(qb_key, qb_key, {
        :site                 => "https://oauth.intuit.com",
        :request_token_path   => "/oauth/v1/get_request_token",
        :authorize_path       => "/oauth/v1/get_access_token",
        :access_token_path    => "/oauth/v1/get_access_token"
    })
    @oauth = OAuth::AccessToken.new(@oauth_consumer, "blah", "blah")

    @service = Quickeebooks::Online::Service::CompanyMetaData.new
    @service.access_token = @oauth
    @service.instance_eval {
      @realm_id = "9991111222"
    }
  end

  describe '#load' do
    it "makes a request for the company associated with the realm ID" do
      xml = onlineFixture("company_meta_data.xml")
      url = @service.url_for_resource(Quickeebooks::Online::Model::CompanyMetaData.resource_for_singular)
      stub_request(:get, url).to_return(:status => ["200", "OK"], :body => xml)
      company_meta_data_response = @service.load
      company_meta_data_response.registered_company_name.should == "Bay Area landscape services"
    end

    it "raises an IntuitRequestException for a 400 response" do
      xml = onlineFixture("no_destination_found.html")
      url = @service.url_for_resource(Quickeebooks::Online::Model::CompanyMetaData.resource_for_singular)
      stub_request(:get, url).to_return(:status => ["400", "Bad Request"], :body => xml)
      lambda { @service.load }.should \
        raise_error(IntuitRequestException, "HTTP Status 400 - message=No destination found for given partition key; errorCode=007001; statusCode=400")
    end
  end
end
