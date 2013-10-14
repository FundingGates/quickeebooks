require 'spec_helper'

describe Quickeebooks::Online::Service::ObjectFetcher do
  include ServiceFetcherHelpers

  describe '#call' do
    it "makes a GET request with the correct arguments" do
      model_class = build_model_class
      service_class = build_service_class(resource_url: 'http://intuit.com/some_resource')

      http = build_http
      response = build_response_from_model_class(model_class)
      expect(http).to receive(:get).
        with('http://intuit.com/some_resource', params: {}).
        and_return(response)

      fetcher = described_class.new(model_class, service_class, http)
      fetcher.call
    end

    it "converts the response to an object" do
      model_class = build_model_class(node_name: 'Car') do
        xml_accessor :make, from: 'Make'
        xml_accessor :model, from: 'Model'
        xml_accessor :year, from: 'Year', as: Integer
      end
      service_class = build_service_class

      http = build_http
      body = build_body_from_model_class(model_class, content: <<-EOT)
        <Make>Ford</Make>
        <Model>Mustang</Model>
        <Year>2013</Year>
      EOT
      response = build_response_from_body(body)
      allow(http).to receive(:get).and_return(response)

      fetcher = described_class.new(model_class, service_class, http)
      object = fetcher.call

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
