shared_examples_for 'Quickeebooks::Shared::Service::AccessToken' do
  context '#disconnect' do
    let(:reconnect_url){ "https://appcenter.intuit.com/api/v1/Connection/Reconnect" }

    it "can successfully reconnect" do
      xml = sharedFixture("reconnect_success.xml")
      stub_request(:get, reconnect_url).to_return(:status => ["200", "OK"], :body => xml)

      response = subject.reconnect

      response.error?.should    be_false
      response.token.should  == "qye2eIdQ5H5yMyrlJflUWh712xfFXjyNnW1MfbC0rz04TfCP"
      response.secret.should == "cyDeUNQTkFzoR0KkDn7viN6uLQxWTobeEUKW7I79"
    end

    it "can handle expired tokens" do
      xml = sharedFixture("reconnect_error_expired.xml")
      stub_request(:get, reconnect_url).to_return(:status => ["200", "OK"], :body => xml)

      response = subject.reconnect

      response.error?.should        be_true
      response.error_code.should    == "270"
      response.error_message.should == "OAuth Token Rejected"
    end

    it "can handle out-of-bounds refresh windows" do
      xml = sharedFixture("reconnect_error_out_of_bounds.xml")
      stub_request(:get, reconnect_url).to_return(:status => ["200", "OK"], :body => xml)

      response = subject.reconnect

      response.error?.should        be_true
      response.error_code.should    == "212"
      response.error_message.should == "Token Refresh Window Out of Bounds"
    end


    it "can handle unapproved apps" do
      xml = sharedFixture("reconnect_error_not_approved.xml")
      stub_request(:get, reconnect_url).to_return(:status => ["200", "OK"], :body => xml)

      response = subject.reconnect

      response.error?.should        be_true
      response.error_code.should    == "24"
      response.error_message.should == "Invalid App Token"
    end
  end

  describe '#disconnect' do
    let(:disconnect_url){ "https://appcenter.intuit.com/api/v1/Connection/Disconnect" }

    it "can successfully disconnect" do
      xml = sharedFixture("disconnect_success.xml")
      stub_request(:get, disconnect_url).to_return(:status => ["200", "OK"], :body => xml)

      response = subject.disconnect

      response.error?.should be_false
    end

    it "can handle invalid tokens" do
      xml = sharedFixture("disconnect_invalid.xml")
      stub_request(:get, disconnect_url).to_return(:status => ["200", "OK"], :body => xml)

      response = subject.disconnect

      response.error?.should        be_true
      response.error_code.should    == "270"
      response.error_message.should == "OAuth Token rejected"
    end
  end
end
