describe "Quickeebooks::Online::Service::SalesTerm" do
  before(:all) do
    construct_online_service(:sales_term)
  end

  it "can fetch a sales term by id" do
    xml = onlineFixture("sales_term.xml")
    url = @service.url_for_resource(Quickeebooks::Online::Model::SalesTerm.resource_for_singular)
    url = "#{url}/99?idDomain=QB"
    FakeWeb.register_uri(:get, url, :status => ["200", "OK"], :body => xml)
    sales_term = @service.fetch_by_id(99)

    sales_term.id.value.should == '3'
    sales_term.sync_token.should == 0
    sales_term.meta_data.create_time.should == Time.parse('2013-01-17T19:04:19-08:00')
    sales_term.meta_data.last_updated_time.should == Time.parse('2013-01-17T19:04:19-08:00')
    sales_term.name.should == "Net 30"
  end

  context 'when a XML parsing error occurs' do
    it "raises an IntuitRequestException" do
      xml = ''
      url = @service.url_for_resource(Quickeebooks::Online::Model::SalesTerm.resource_for_singular)
      url = "#{url}/99?idDomain=QB"
      FakeWeb.register_uri(:get, url, :status => ["200", "OK"], :body => xml)
      expect{ @service.fetch_by_id(99) }.to raise_error(IntuitRequestException)
    end
  end

end
