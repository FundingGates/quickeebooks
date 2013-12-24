describe "Quickeebooks::Online::Service::Invoice" do
  before(:all) do
    construct_online_service(:invoice)
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
