describe "Quickeebooks::Windows::Service::ShipMethod" do
  before(:all) do
    construct_oauth
  end

  it "can fetch a list of shipping methods" do
    xml = windowsFixture("ship_methods.xml")
    model = Quickeebooks::Windows::Model::ShipMethod
    service = Quickeebooks::Windows::Service::ShipMethod.new
    service.access_token = @oauth
    service.realm_id = @realm_id
    FakeWeb.register_uri(:post, service.url_for_resource(model::REST_RESOURCE), :status => ["200", "OK"], :body => xml)
    shipping_methods = service.list
    shipping_methods.entries.count.should == 15

    vinlux = shipping_methods.entries.detect { |sm| sm.name == "Vinlux" }
    vinlux.should_not == nil
    vinlux.id.value.should == "13"
  end

end