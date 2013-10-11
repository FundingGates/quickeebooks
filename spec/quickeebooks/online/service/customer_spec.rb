describe "Quickeebooks::Online::Service::Customer" do
  before(:all) do
    FakeWeb.allow_net_connect = false
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

    @service = Quickeebooks::Online::Service::Customer.new
    @service.access_token = @oauth
    @service.instance_eval {
      @realm_id = "9991111222"
    }
  end

  it "can fetch a list of customers" do
    xml = onlineFixture("customers.xml")
    url = @service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_collection)
    FakeWeb.register_uri(:post, url, :status => ["200", "OK"], :body => xml)
    accounts = @service.list
    accounts.current_page.should == 1
    accounts.entries.count.should == 3
    accounts.entries.first.name.should == "John Doe"
  end

  it "handles 400 errors which are in the form of HTML when making a list request" do
    xml = onlineFixture("no_destination_found.html")
    url = @service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_collection)
    FakeWeb.register_uri(:post, url, :status => ["400", "Bad Request"], :body => xml)
    lambda { @service.list }.should \
      raise_error(IntuitRequestException, "HTTP Status 400 - message=No destination found for given partition key; errorCode=007001; statusCode=400")
  end

  it "can fetch a list of customers with filters" do
    xml = onlineFixture("customers.xml")
    url = @service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_collection)
    FakeWeb.register_uri(:post, url, :status => ["200", "OK"], :body => xml)
    accounts = @service.list
    accounts.current_page.should == 1
    accounts.entries.count.should == 3
    accounts.entries.first.name.should == "John Doe"
  end

  it "can create a customer" do
    xml = onlineFixture("customer.xml")
    url = @service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_singular)
    FakeWeb.register_uri(:post, url, :status => ["200", "OK"], :body => xml)
    customer = Quickeebooks::Online::Model::Customer.new
    customer.name = "Billy Bob"
    result = @service.create(customer)
    result.id.value.to_i.should > 0
  end

  it "can delete a customer" do
    url = @service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_singular)
    url = "#{url}/99?methodx=delete"
    FakeWeb.register_uri(:post, url, :status => ["200", "OK"])
    customer = Quickeebooks::Online::Model::Customer.new
    customer.id = Quickeebooks::Online::Model::Id.new("99")
    customer.sync_token = 0
    result = @service.delete(customer)
    result.should == true
  end

  it "cannot delete a customer with missing required fields for deletion" do
    customer = Quickeebooks::Online::Model::Customer.new
    lambda { @service.delete(customer) }.should raise_error(InvalidModelException, "Missing required parameters for delete")
  end

  it "exception is raised when we try to create an invalid account" do
    customer = Quickeebooks::Online::Model::Customer.new
    lambda { @service.create(customer) }.should raise_error(InvalidModelException)
  end

  it "cannot update an invalid customer" do
    customer = Quickeebooks::Online::Model::Customer.new
    customer.name = "John Doe"
    lambda { @service.update(customer) }.should raise_error(InvalidModelException)
  end

  describe '#fetch_by_id' do
    it "returns the customer if it can be found" do
      xml = onlineFixture("customer.xml")
      url = "#{@service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_singular)}/99"
      FakeWeb.register_uri(:get, url, :status => ["200", "OK"], :body => xml)
      customer = @service.fetch_by_id(99)
      customer.name.should == "John Doe"
    end

    it "returns nil if the customer cannot be found" do
      xml = onlineFixture("customer_not_found.xml")
      url = "#{@service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_singular)}/99"
      FakeWeb.register_uri(:get, url, :status => ["400", "Bad Request"], :body => xml)
      @service.fetch_by_id(99).should eq nil
    end
  end

  it "can update a customer" do
    xml2 = onlineFixture("customer2.xml")
    customer = Quickeebooks::Online::Model::Customer.new
    customer.name = "John Doe"
    customer.id = Quickeebooks::Online::Model::Id.new("1")
    customer.sync_token = 2

    url = "#{@service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_singular)}/#{customer.id.value}"
    FakeWeb.register_uri(:post, url, :status => ["200", "OK"], :body => xml2)
    updated = @service.update(customer)
    updated.name.should == "Billy Bob"
  end

  it 'Can update a fetched customer' do
    xml = onlineFixture("customer.xml")
    url = "#{@service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_singular)}/99"
    FakeWeb.register_uri(:get, url, :status => ["200", "OK"], :body => xml)
    customer = @service.fetch_by_id(99)
    url = "#{@service.url_for_resource(Quickeebooks::Online::Model::Customer.resource_for_singular)}/#{customer.id.value}"
    FakeWeb.register_uri(:post, url, :status => ["200", "OK"], :body => xml)
    updated = @service.update(customer)
  end

end
