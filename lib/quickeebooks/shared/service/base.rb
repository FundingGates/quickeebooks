require 'forwardable'

module Quickeebooks
  module Shared
    module Service
      class Base
        def self.resource_url
          base_url
        end

        XML_NS = %{xmlns:ns2="http://www.intuit.com/sb/cdm/qbo" xmlns="http://www.intuit.com/sb/cdm/v2" xmlns:ns3="http://www.intuit.com/sb/cdm"}

        attr_accessor :access_token, :realm_id

        def initialize(access_token = nil, realm_id = nil)
          self.access_token = access_token
          self.realm_id = realm_id
        end

        def url_for_base(path)
          build_url(self.class.base_url, path)
        end

        def url_for_resource(path)
          build_url(self.class.resource_url, path)
        end

        def on_request(&block)
          @on_request = block
        end

        private

        extend Forwardable
        def_delegators :access_token, :consumer

        def build_url(base_url, path)
          "#{base_url}/#{path}/v2/#{realm_id}"
        end

        def valid_xml_document(xml)
          %Q{<?xml version="1.0" encoding="utf-8"?>\n#{xml.strip}}
        end

        def do_http_post(url, body = "", params = {}, headers = {})
          url = add_query_string_to_url(url, params)
          do_http(:post, url, body, headers)
        end

        def do_http_get(url, params = {}, headers = {})
          url = add_query_string_to_url(url, params)
          do_http(:get, url, "", headers)
        end

        def add_query_string_to_url(url, params)
          if params.is_a?(Hash) && !params.empty?
            url + "?" + params.collect { |k| "#{k.first}=#{k.last}" }.join("&")
          else
            url
          end
        end

        def do_http(method, url, body, headers)
          headers = {'Content-Type' => 'application/xml'}.merge(headers)

          request = nil
          extra_arguments = []
          if [:post, :put].include?(method)
            extra_arguments << body
          end
          extra_arguments << headers
          response = access_token.consumer.request(method, url, access_token, {}, *extra_arguments) do |req|
            request = Request.new(req)
            request.uri = url
          end
          response = Response.new(response)

          fire_on_request(request, response)

          check_response(response)
        end

        def parse_xml(xml)
          Nokogiri::XML.parse(xml)
        end

        def fire_on_request(request, response)
          if @on_request
            @on_request.call(request, response)
          end
        end

        def request(method, url, *args, &block)
          consumer.request(method, url, access_token, {}, *args, &block)
        end
      end
    end
  end
end
