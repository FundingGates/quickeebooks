require 'spec_helper'

describe Quickeebooks::Online::Service::Item do
  describe '#list' do
    it "makes a request for a collection of items"
  end

  describe '#create' do
    it "uses the given item to make a create request"

    it "raises an InvalidModelException given an invalid item"
  end

  describe '#update' do
    it "uses the given item to make an update request"

    it "accepts an Item object returned by #fetch_by_id"

    it "raises an InvalidModelException given an invalid item"
  end

  describe '#fetch_by_id' do
    it "makes a request for a single item"

    it "returns nil if the item cannot be found"
  end

  describe '#delete' do
    it "uses the given item to make a delete request"

    it "raises an InvalidModelException given an invalid item"
  end
end
