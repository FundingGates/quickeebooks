require 'spec_helper'

describe "Quickeebooks::Online::Service::Account" do
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

    @service = Quickeebooks::Online::Service::Account.new
    @service.access_token = @oauth
    @service.instance_eval {
      @realm_id = "9991111222"
    }
  end

  it "receives 404 from invalid base URL" do
    pending "this test doesn't really test anything!!"

    uri = "https://qbo.intuit.com/invalid"
    url = @service.url_for_resource(Quickeebooks::Online::Model::Account.resource_for_collection)
    stub_request(:post, url).to_return(:status => ["200", "OK"], :body => "blah")
    lambda { @service.list }.should raise_error(IntuitRequestException)
  end

  describe '#list' do
    it "makes a request for a collection of accounts" do
      xml = File.read(File.dirname(__FILE__) + "/../../../xml/online/accounts.xml")
      url = @service.url_for_resource(Quickeebooks::Online::Model::Account.resource_for_collection)
      stub_request(:post, url).to_return(:status => ["200", "OK"], :body => xml)
      accounts = @service.list
      accounts.current_page.should == 1
      accounts.entries.count.should == 10
      accounts.entries.first.current_balance.should == 6200
    end

    it "raises an IntuitRequestException for a 400 response" do
      xml = onlineFixture("no_destination_found.html")
      url = @service.url_for_resource(Quickeebooks::Online::Model::Account.resource_for_collection)
      stub_request(:post, url).to_return(:status => ["400", "Bad Request"], :body => xml)
      lambda { @service.list }.should \
        raise_error(IntuitRequestException, "HTTP Status 400 - message=No destination found for given partition key; errorCode=007001; statusCode=400")
    end
  end

  describe '#create' do
    it "uses the given account to make a create request" do
      xml = File.read(File.dirname(__FILE__) + "/../../../xml/online/account.xml")
      url = @service.url_for_resource(Quickeebooks::Online::Model::Account.resource_for_singular)
      stub_request(:post, url).to_return(:status => ["200", "OK"], :body => xml)
      account = Quickeebooks::Online::Model::Account.new
      account.name = "Billy Bob"
      account.sub_type = "AccountsPayable"
      account.valid?.should == true
      result = @service.create(account)
      result.id.to_i.should > 0
    end

    it "raises an InvalidModelException given an invalid account" do
      account = Quickeebooks::Online::Model::Account.new
      lambda { @service.create(account) }.should raise_error(InvalidModelException)
    end
  end

  describe '#delete' do
    it "uses the given account to make a delete request" do
      url = @service.url_for_resource(Quickeebooks::Online::Model::Account.resource_for_singular)
      url = "#{url}/99?methodx=delete"
      stub_request(:post, url).to_return(:status => ["200", "OK"])
      account = Quickeebooks::Online::Model::Account.new
      account.id = 99
      account.sync_token = 0
      result = @service.delete(account)
      result.should == true
    end

    it "raises an InvalidModelException given an invalid account" do
      account = Quickeebooks::Online::Model::Account.new
      lambda { @service.delete(account) }.should raise_error(InvalidModelException, "Missing required parameters for delete")
    end
  end

  describe '#fetch_by_id' do
    it "makes a request for a single account" do
      xml = onlineFixture("account.xml")
      url = @service.url_for_resource(Quickeebooks::Online::Model::Account.resource_for_singular)
      url = "#{url}/99"
      stub_request(:get, url).to_return(:status => ["200", "OK"], :body => xml)
      account = @service.fetch_by_id(99)
      account.name.should == "Billy Bob"
    end
  end
end
