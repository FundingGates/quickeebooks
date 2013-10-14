require 'spec_helper'

describe Quickeebooks::Shared::Service::GetRequestPerformer do
  include RequestPerformerHelpers

  describe '#call' do
    it_behaves_like 'RequestPerformer#call'

    it "calls OauthConsumer#request with the request method, URL, and access token" do
      consumer = build_consumer
      access_token = build_access_token(consumer)
      response_handler = build_response_handler

      http = described_class.new(access_token, response_handler)
      http.call('http://foo.com')

      expect(consumer).to have_received(:request) do |passed_method, passed_url, passed_access_token, *rest|
        expect(passed_method).to eq :get
        expect(passed_url).to eq 'http://foo.com'
        expect(passed_access_token).to eq access_token
      end
    end

    it "appends query parameters to the end of the URL" do
      consumer = build_consumer
      access_token = build_access_token(consumer)
      response_handler = build_response_handler

      http = described_class.new(access_token, response_handler)
      http.call('http://foo.com', params: {'foo!bar' => 'baz@qux'})

      expect(consumer).to have_received(:request) do |_, passed_url, *rest|
        expect(passed_url).to eq 'http://foo.com?foo%21bar=baz%40qux'
      end
    end

    it "passes along provided headers" do
      consumer = build_consumer
      access_token = build_access_token(consumer)
      response_handler = build_response_handler
      url = 'http://foo.com'
      headers = {'foo' => 'bar'}

      http = described_class.new(access_token, response_handler)
      http.call(url, headers: headers)

      expect(consumer).to have_received(:request) do |_, _, _, _, passed_headers|
        expect(passed_headers).to eq hash_including(headers)
      end
    end
  end
end
