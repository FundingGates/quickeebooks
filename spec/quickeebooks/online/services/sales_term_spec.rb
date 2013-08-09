describe "Quickeebooks::Online::Service::SalesTerm" do
  before(:all) do
    FakeWeb.allow_net_connect = false
    qb_key = "key"
    qb_secret = "secreet"

    @realm_id = "9991111222"
    @base_uri = "https://qbo.intuit.com/qbo36"
    @oauth_consumer = OAuth::Consumer.new(qb_key, qb_key, {
        :site                 => "https://oauth.intuit.com",
        :request_token_path   => "/oauth/v1/get_request_token",
        :authorize_path       => "/oauth/v1/get_access_token",
        :access_token_path    => "/oauth/v1/get_access_token"
    })
    @oauth = OAuth::AccessToken.new(@oauth_consumer, "blah", "blah")

    @service = Quickeebooks::Online::Service::SalesTerm.new
    @service.access_token = @oauth
    @service.instance_eval {
      @realm_id = "9991111222"
    }
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
end
