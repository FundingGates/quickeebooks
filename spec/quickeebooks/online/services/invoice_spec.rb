describe "Quickeebooks::Online::Service::Invoice" do
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
    @service = Quickeebooks::Online::Service::Invoice.new
    @service.access_token = @oauth
    @service.instance_eval {
      @realm_id = "9991111222"
    }
  end

  it "can create an invoice" do
    xml = onlineFixture("invoice.xml")

    url = @service.url_for_resource(Quickeebooks::Online::Model::Invoice.resource_for_singular)
    FakeWeb.register_uri(:post, url, :status => ["200", "OK"], :body => xml)
    invoice = Quickeebooks::Online::Model::Invoice.new
    invoice.header = Quickeebooks::Online::Model::InvoiceHeader.new
    invoice.header.doc_number = "123"

    line_item = Quickeebooks::Online::Model::InvoiceLineItem.new
    line_item.item_id = Quickeebooks::Online::Model::Id.new("123")
    line_item.desc = "Pinor Noir 2005"
    line_item.unit_price = 188
    line_item.quantity = 2
    invoice.line_items << line_item

    result = @service.create(invoice)
    result.id.value.to_i.should > 0
  end

  it "handles 400 errors which are in the form of HTML when making a list request" do
    xml = onlineFixture("no_destination_found.html")
    url = @service.url_for_resource(Quickeebooks::Online::Model::Invoice.resource_for_collection)
    FakeWeb.register_uri(:post, url, :status => ["400", "Bad Request"], :body => xml)
    lambda { @service.list }.should \
      raise_error(IntuitRequestException, "HTTP Status 400 - message=No destination found for given partition key; errorCode=007001; statusCode=400")
  end
end
