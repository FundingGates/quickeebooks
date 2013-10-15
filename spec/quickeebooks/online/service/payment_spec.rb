require 'spec_helper'

describe Quickeebooks::Online::Service::Payment do
  describe '#create' do
    it "uses the given payment to make a create request"

    it "raises an InvalidModelException given an invalid payment"
  end

  describe '#fetch_by_id' do
    it "makes a request for a single payment"
  end

  describe '#update' do
    it "uses the given payment to make an update request"

    it "accepts a Payment object returned by #fetch_by_id"

    it "raises an InvalidModelException given an invalid request"
  end

  describe '#list' do
    it "makes a request for a collection of payments"
  end
end
