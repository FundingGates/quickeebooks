require 'spec_helper'

describe "Quickeebooks::Online::Service::Invoice" do
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
    @service = Quickeebooks::Online::Service::Invoice.new
    @service.access_token = @oauth
    @service.instance_eval {
      @realm_id = "9991111222"
    }
  end

  describe '#create' do
    it "uses the given invoice to make a create request" do
      xml = onlineFixture("invoice.xml")

      url = @service.url_for_resource(Quickeebooks::Online::Model::Invoice.resource_for_singular)
      stub_request(:post, url).to_return(:status => ["200", "OK"], :body => xml)
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

    it "raises an InvalidModelException given an invalid invoice"
  end

  describe '#fetch_by_id' do
    it "makes a request for a single invoice"
  end

  describe '#update' do
    it "uses the given customer to make an update request"

    it "accepts an Invoice object returned by #fetch_by_id"

    it "raises an InvalidModelException given an invalid invoice"
  end

  describe '#list' do
    it "makes a request for a collection of invoices"

    it "raises an IntuitRequestException for a 400 response" do
      xml = onlineFixture("no_destination_found.html")
      url = @service.url_for_resource(Quickeebooks::Online::Model::Invoice.resource_for_collection)
      stub_request(:post, url).to_return(:status => ["400", "Bad Request"], :body => xml)
      lambda { @service.list }.should \
        raise_error(IntuitRequestException, "HTTP Status 400 - message=No destination found for given partition key; errorCode=007001; statusCode=400")
    end
  end

  describe '#invoice_as_pdf' do
    it "makes a request for the PDF version of an invoice and writes it to file"
  end

  describe '#delete' do
    it "uses the given invoice to make a delete request"

    it "raises an InvalidModelException given an invalid invoice"
  end
end
