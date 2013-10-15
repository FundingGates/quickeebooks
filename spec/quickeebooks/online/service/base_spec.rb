require 'spec_helper'

describe Quickeebooks::Online::Service::Base do
  include ServiceHelpers

  it_behaves_like 'Quickeebooks::Shared::Service::Base'

  describe '#login_name' do
    it "returns the login name of the user" do
      access_token = build_access_token
      body = read_qbo_fixture('user.xml')
      stub_request(:get, "https://qbo.intuit.com/qbo1/rest/user/v2/#{fake_realm_id}").
        to_return(body: body)

      service = described_class.new(access_token, fake_realm_id)
      expect(service.login_name).to eq 'foo@example.com'
    end

    it "caches the result so only one request is made" do
      access_token = build_access_token
      body = read_qbo_fixture('user.xml')
      stub_request(:get, "https://qbo.intuit.com/qbo1/rest/user/v2/#{fake_realm_id}").
        to_return(body: body).then.
        to_raise('this should never get raised')

      service = described_class.new(access_token, fake_realm_id)
      service.login_name
      service.login_name
    end
  end
end
