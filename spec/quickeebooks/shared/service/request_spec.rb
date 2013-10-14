require 'spec_helper'

describe Quickeebooks::Shared::Service::Request do
  describe '#method' do
    it "returns the request method" do
      delegate_request = double(method: 'get')
      request = described_class.new(delegate_request)
      expect(request.method).to eq 'get'
    end
  end
end
