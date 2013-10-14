require 'spec_helper'

describe Quickeebooks::Online::Service::CollectionFetcher do
  include ServiceFetcherHelpers

  describe '#call' do
    it "makes a POST request with the correct arguments" do
      model_class = build_model_class
      service_class = build_service_class(collection_url: 'http://intuit.com/some_collection')

      http = build_http
      response = build_response_from_model_class(model_class)
      body = {
        'PageNum' => 1,
        'ResultsPerPage' => 20
      }
      expect(http).to receive(:post).
        with('http://intuit.com/some_collection', body: body).
        and_return(response)

      fetcher = described_class.new(model_class, service_class, http)
      fetcher.call
    end

    it "converts the response to a Quickeebooks::Collection" do
      model_class = build_model_class(node_name: 'Car') do
        xml_accessor :make, from: 'Make'
        xml_accessor :model, from: 'Model'
        xml_accessor :year, from: 'Year', as: Integer
      end
      service_class = build_service_class

      http = build_http
      body = build_body_from_model_class(model_class, items: [<<-FIRST, <<-SECOND], current_page: 42)
        <Make>Ford</Make>
        <Model>Mustang</Model>
        <Year>2013</Year>
      FIRST
        <Make>Chevy</Make>
        <Model>Silverado</Model>
        <Year>2010</Year>
      SECOND
      response = build_response_from_body(body)
      allow(http).to receive(:post).and_return(response)

      fetcher = described_class.new(model_class, service_class, http)
      collection = fetcher.call

      expect(collection.count).to eq 2
      expect(collection.current_page).to eq 42

      entries = collection.entries
      expect(entries[0].make).to eq 'Ford'
      expect(entries[0].model).to eq 'Mustang'
      expect(entries[0].year).to eq 2013
      expect(entries[1].make).to eq 'Chevy'
      expect(entries[1].model).to eq 'Silverado'
      expect(entries[1].year).to eq 2010
    end

    it "allows the page number to be overridden" do
      model_class = build_model_class
      service_class = build_service_class(collection_url: 'http://intuit.com/some_collection')

      http = build_http
      response = build_response_from_model_class(model_class)
      body = hash_including('PageNum' => 10)
      expect(http).to receive(:post).
        with('http://intuit.com/some_collection', body: body).
        and_return(response)

      fetcher = described_class.new(model_class, service_class, http)
      fetcher.call(page: 10)
    end

    it "allows the number of results per page to be overridden" do
      model_class = build_model_class
      service_class = build_service_class(collection_url: 'http://intuit.com/some_collection')

      http = build_http
      response = build_response_from_model_class(model_class)
      body = hash_including('ResultsPerPage' => 100)
      expect(http).to receive(:post).
        with('http://intuit.com/some_collection', body: body).
        and_return(response)

      fetcher = described_class.new(model_class, service_class, http)
      fetcher.call(per_page: 100)
    end

    it "allows filters to be provided" do
      model_class = build_model_class
      service_class = build_service_class(collection_url: 'http://intuit.com/some_collection')

      http = build_http
      response = build_response_from_model_class(model_class)
      body = hash_including('Filter' => 'TxnDate :AND: CreateTime')
      expect(http).to receive(:post).
        with('http://intuit.com/some_collection', body: body).
        and_return(response)

      fetcher = described_class.new(model_class, service_class, http)
      fetcher.call(filters: %w(TxnDate CreateTime))
    end

    it "allows the sort parameter to be provided" do
      model_class = build_model_class
      service_class = build_service_class(collection_url: 'http://intuit.com/some_collection')

      http = build_http
      response = build_response_from_model_class(model_class)
      body = hash_including('Sort' => 'CreateTime')
      expect(http).to receive(:post).
        with('http://intuit.com/some_collection', body: body).
        and_return(response)

      fetcher = described_class.new(model_class, service_class, http)
      fetcher.call(sort: 'CreateTime')
    end
  end

  def build_body(node_name, options = {})
    items = options.fetch(:items, [])
    current_page = options.fetch(:current_page, 1)
    items_with_containers = items.map { |item| "<#{node_name}>#{item}</#{node_name}" }
    <<-EOT
      <qbo:SearchResults xmlns="http://intuit.com/namespace" xmlns:qbo="http://intuit.com/namespace2">
        <qbo:CdmCollections>
          #{items_with_containers.join("\n")}
        </qbo:CdmCollections>
        <qbo:Count>#{items_with_containers.size}</qbo:Count>
        <qbo:CurrentPage>#{current_page}</qbo:CurrentPage>
      </qbo:SearchResults>
    EOT
  end
end
