describe "Quickeebooks::Windows::Service::Clazz" do
  before(:all) do
    construct_oauth
  end

  it "can fetch a list of classes" do
    xml = windowsFixture("classes.xml")
    model = Quickeebooks::Windows::Model::Clazz
    service = Quickeebooks::Windows::Service::Clazz.new
    service.access_token = @oauth
    service.realm_id = @realm_id
    FakeWeb.register_uri(:post, service.url_for_resource(model::REST_RESOURCE), :status => ["200", "OK"], :body => xml)
    classes = service.list
    classes.entries.count.should == 3
    entry = classes.entries.first
    entry.name.should == "Bugay"
    entry.id.to_i.should == 157
    entry.active?.should == true
  end

end