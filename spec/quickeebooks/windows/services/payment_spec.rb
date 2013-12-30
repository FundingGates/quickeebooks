describe "Quickeebooks::Windows::Service::Payment" do
  before(:all) do
    construct_oauth
  end

  it "can fetch a list of payments" do
    xml = windowsFixture("payments.xml")
    service = Quickeebooks::Windows::Service::Payment.new
    service.access_token = @oauth
    service.realm_id = @realm_id

    model = Quickeebooks::Windows::Model::Payment
    FakeWeb.register_uri(:post,
                         service.url_for_resource(model::REST_RESOURCE),
                         :status => ["200", "OK"],
                         :body => xml)
    payments = service.list
    payments.entries.count.should == 1

    payment = payments.entries.first
    payment.id.value.should == "4"
    payment.header.should_not be_nil
    header = payment.header
    header.customer_name.should == "Davis"

    payment.external_key.should == "4"

    line1 = payment.line_items.first
    line1.should_not be_nil
    line1.amount.should == header.total_amount
  end
end
