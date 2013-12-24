describe "Quickeebooks::Online::Service::CompanyMetaData" do
  before(:all) do
    construct_online_service(:company_meta_data)
  end

  it "can get the realm's company_meta_data record" do
    xml = onlineFixture("company_meta_data.xml")
    url = @service.url_for_resource(Quickeebooks::Online::Model::CompanyMetaData.resource_for_singular)
    FakeWeb.register_uri(:get, url, :status => ["200", "OK"], :body => xml)
    company_meta_data_response = @service.load
    company_meta_data_response.registered_company_name.should == "Bay Area landscape services"
  end

  it "handles 400 errors which are in the form of HTML when making a list request" do
    xml = onlineFixture("no_destination_found.html")
    url = @service.url_for_resource(Quickeebooks::Online::Model::CompanyMetaData.resource_for_singular)
    FakeWeb.register_uri(:get, url, :status => ["400", "Bad Request"], :body => xml)
    lambda { @service.load }.should \
      raise_error(IntuitRequestException, "HTTP Status 400 - message=No destination found for given partition key; errorCode=007001; statusCode=400")
  end
end
