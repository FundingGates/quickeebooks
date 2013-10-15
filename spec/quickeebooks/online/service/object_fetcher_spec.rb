require 'spec_helper'

describe Quickeebooks::Online::Service::ObjectFetcher do
  include ServiceFetcherHelpers

  describe '#call' do
    it "makes a GET request with the correct arguments" do
      model_class = build_model_class
      response = build_response_from_model_class(model_class)
      http = build_http(:get, response)
      service = build_service(
        resource_url: 'http://intuit.com/some_resource',
        http: http
      )

      fetcher = described_class.new(service)
      fetcher.call(model_class)

      expect(http).to have_received(:get) do |url, _|
        expect(url).to eq 'http://intuit.com/some_resource'
      end
    end

    it "passes any query parameters along" do
      model_class = build_model_class
      response = build_response_from_model_class(model_class)
      http = build_http(:get, response)
      service = build_service(http: http)
      params = {foo: 'bar'}

      fetcher = described_class.new(service)
      fetcher.call(model_class, params: params)

      expect(http).to have_received(:get) do |_, options|
        expect(options[:params]).to eq params
      end
    end

    it "converts the response to an object" do
      model_class = build_model_class(node_name: 'Car') do
        xml_accessor :make, from: 'Make'
        xml_accessor :model, from: 'Model'
        xml_accessor :year, from: 'Year', as: Integer
      end
      body = build_body_from_model_class(model_class, content: <<-EOT)
        <Make>Ford</Make>
        <Model>Mustang</Model>
        <Year>2013</Year>
      EOT
      response = build_response_from_body(body)
      http = build_http(:get, response)
      service = build_service(http: http)

      fetcher = described_class.new(service)
      object = fetcher.call(model_class)

      expect(object.make).to eq 'Ford'
      expect(object.model).to eq 'Mustang'
      expect(object.year).to eq 2013
    end
  end

  def build_body(node_name, options = {})
    <<-EOT
      <#{node_name} xmlns="http://intuit.com/namespace">
        #{options[:content]}
      </#{node_name}>
    EOT
  end
end
