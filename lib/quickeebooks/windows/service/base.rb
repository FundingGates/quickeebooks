require 'rexml/document'
require 'uri'
require 'cgi'
require 'uuidtools'

module Quickeebooks
  module Windows
    module Service
      class Base < Quickeebooks::Shared::Service::Base
        def self.base_url
          'https://services.intuit.com/sb'
        end

        attr_reader :last_response_body
        attr_reader :last_response_xml

        def url_for_resource(resource)
          url_for_base(resource)
        end

        def guid
          UUIDTools::UUID.random_create.to_s.gsub('-', '')
        end

        private

        def parse_xml(xml)
          @last_response_xml =
          begin
            x = Nokogiri::XML(xml)
            #x.document.remove_namespaces!
            x
          end
        end

        # In QBD a single object response is the same as a collection response except
        # it just has a single main element
        def fetch_object(model, url, params = {}, options = {})
          raise ArgumentError, "missing model to instantiate" if model.nil?
          response = do_http_get(url, params, {'Content-Type' => 'text/xml'})
          collection = parse_collection(response, model)
          if collection.is_a?(Quickeebooks::Collection)
            collection.entries.first
          else
            nil
          end
        end

        def fetch_collection(model, custom_field_query = nil, filters = [], page = 1, per_page = 20, sort = nil, options ={})
          raise ArgumentError, "missing model to instantiate" if model.nil?

          post_body_tags = []

          post_body_tags << "<StartPage>#{page}</StartPage>"
          post_body_tags << "<ChunkSize>#{per_page}</ChunkSize>"

          if filters.is_a?(Array) && filters.length > 0
            post_body_tags << filters.collect { |f| f.to_xml }
            post_body_tags.flatten!
          end

          if sort
            post_body_tags << sort.to_xml
          end

          post_body_tags << custom_field_query

          xml_query_tag = "#{model::XML_NODE}Query"
          body = %Q{<?xml version="1.0" encoding="utf-8"?>\n<#{xml_query_tag} xmlns="http://www.intuit.com/sb/cdm/v2">#{post_body_tags.join}</#{xml_query_tag}>}

          response = do_http_post(url_for_resource(model::REST_RESOURCE), body, {}, {'Content-Type' => 'text/xml'})
          parse_collection(response, model)
        end

        def parse_collection(response, model)
          if response
            collection = Quickeebooks::Collection.new
            xml = @last_response_xml
            begin
              results = []
              path_to_nodes = "//xmlns:RestResponse/xmlns:#{model::XML_COLLECTION_NODE}/xmlns:#{model::XML_NODE}"
              collection.count = xml.xpath(path_to_nodes).count
              if collection.count > 0
                xml.xpath(path_to_nodes).each do |xa|
                  entry = model.from_xml(xa)
                  results << entry
                end
              end
              collection.entries = results
              collection.current_page = 1 # TODO: fix this
            rescue => ex
              #log("Error parsing XML: #{ex.message}")
              raise IntuitRequestException.new("Error parsing XML: #{ex.message}")
            end
            collection
          else
            nil
          end
        end

        def perform_write(model, body = "", params = {}, headers = {})
          url = url_for_resource(model::REST_RESOURCE)
          unless headers.has_key?('Content-Type')
            headers['Content-Type'] = 'text/xml'
          end
          response = do_http_post(url, body.strip, params, headers)

          result = nil
          if response
            case response.code.to_i
            when 200
              result = Quickeebooks::Windows::Model::RestResponse.from_xml(response.body)
            when 401
              raise IntuitRequestException.new("Authorization failure: token timed out?")
            when 404
              raise IntuitRequestException.new("Resource Not Found: Check URL and try again")
            end
          end
          result
        end

        def check_response(response)
          parse_xml(response.body)
          status = response.code.to_i
          case status
          when 200
            # even HTTP 200 can contain an error, so we always have to peek for an Error
            if response_is_error?
              parse_and_raise_exceptione
            else
              response
            end
          when 302
            raise "Unhandled HTTP Redirect"
          when 401
            raise AuthorizationFailure
          when 400, 500
            parse_and_raise_exceptione
          else
            raise "HTTP Error Code: #{status}, Msg: #{response.body}"
          end
        end

        def parse_and_raise_exceptione
          err = parse_intuit_error
          ex = IntuitRequestException.new(err[:message])
          ex.code = err[:code]
          ex.cause = err[:cause]
          raise ex
        end

        def response_is_error?
          @last_response_xml.xpath("//xmlns:RestResponse/xmlns:Error").first != nil
        rescue Nokogiri::XML::XPath::SyntaxError => e
          unless e.message =~ /Undefined namespace prefix/
            raise e
          end
        end

        def parse_intuit_error
          error = {:message => "", :code => 0, :cause => ""}
          fault = @last_response_xml.xpath("//xmlns:RestResponse/xmlns:Error/xmlns:ErrorDesc")[0]
          if fault
            error[:message] = fault.text
          end
          error_code = @last_response_xml.xpath("//xmlns:RestResponse/xmlns:Error/xmlns:ErrorCode")[0]
          if error_code
            error[:code] = error_code.text
          end
          error
        end
      end
    end
  end
end