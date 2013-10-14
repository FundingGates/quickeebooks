require 'spec_helper'

describe Quickeebooks::Shared::Service::GetRequestPerformer do
  include RequestPerformerHelpers

  describe '#call' do
    it_behaves_like 'RequestPerformer#call'

    it "calls OauthConsumer#request with the request method, URL, and access token" do
      service = build_service
      request_performer = described_class.new(service)

      request_performer.call('http://foo.com')

      expect(service).to have_received(:request) do |passed_method, passed_url, *rest|
        expect(passed_method).to eq :get
        expect(passed_url).to eq 'http://foo.com'
      end
    end

    it "appends query parameters to the end of the URL" do
      service = build_service
      request_performer = described_class.new(service)

      request_performer.call('http://foo.com', params: {'foo!bar' => 'baz@qux'})

      expect(service).to have_received(:request) do |_, passed_url, *rest|
        expect(passed_url).to eq 'http://foo.com?foo%21bar=baz%40qux'
      end
    end

    it "passes along provided headers" do
      service = build_service
      url = 'http://foo.com'
      headers = {'foo' => 'bar'}
      request_performer = described_class.new(service)

      request_performer.call(url, headers: headers)

      expect(service).to have_received(:request) do |_, _, passed_headers, *rest|
        expect(passed_headers).to eq hash_including(headers)
      end
    end
  end
end
