require 'rexml/document'
require 'uri'
require 'cgi'

module Quickeebooks
  module Online
    module Service
      class Base < Quickeebooks::Shared::Service::Base
        def self.base_url
          'https://qbo.sbfinance.intuit.com'
        end

        def self.resource_url
          "#{base_url}/resource"
        end

        def login_name
          @login_name ||= begin
            url = build_url('https://qbo.intuit.com/qbo1/rest', 'user')
            response = access_token.request(:get, url)
            if response && response.code.to_i == 200
              xml = parse_xml(response.body)
              xml.xpath("//qbo:QboUser/qbo:LoginName")[0].text
            end
          end
        end

        private

        def fetch_object(model_class, options = {})
          response = http.get(self.class.resource_url, options)
          xml = response.parsed_body
          element = xml.at_xpath("//xmlns:#{model_class.node_name}")
          model_class.from_xml(element)

          #---

          ObjectFetcher.new(self).call(model_class, options)

          #---

          raise ArgumentError, "missing model to instantiate" if model.nil?
          response = do_http_get(url, params, {'Content-Type' => 'text/xml'})

          xml = parse_xml(response.body)
          element = xml.at_xpath("//xmlns:#{model::XML_NODE}")
          model.from_xml(element)
        rescue => ex
          raise IntuitRequestException.new("Error parsing XML: #{ex.message}")
        end

        def fetch_collection(model, filters = [], page = 1, per_page = 20, sort = nil, options ={})
          raise ArgumentError, "missing model to instantiate" if model.nil?

          post_body_lines = []

          if filters.is_a?(Array) && filters.length > 0
            filter_string = filters.collect { |f| f.to_s }
            post_body_lines << "Filter=#{CGI.escape(filter_string.join(" :AND: "))}"
          end

          post_body_lines << "PageNum=#{page}"
          post_body_lines << "ResultsPerPage=#{per_page}"

          if sort
            post_body_lines << "Sort=#{CGI.escape(sort.to_s)}"
          end

          body = post_body_lines.join("&")
          response = do_http_post(url_for_resource(model.resource_for_collection), body, {}, {'Content-Type' => 'application/x-www-form-urlencoded'})

          parse_collection(response, model)
        end

        def parse_collection(response, model)
          if response
            collection = Quickeebooks::Collection.new
            xml = parse_xml(response.body)
            begin
              results = []
              collection.count = xml.xpath("//qbo:SearchResults/qbo:Count")[0].text.to_i
              if collection.count > 0
                xml.xpath("//qbo:SearchResults/qbo:CdmCollections/xmlns:#{model::XML_NODE}").each do |xa|
                  results << model.from_xml(xa)
                end
              end
              collection.entries = results
              collection.current_page = xml.xpath("//qbo:SearchResults/qbo:CurrentPage")[0].text.to_i
            rescue => ex
              #log("Error parsing XML: #{ex.message}")
              raise IntuitRequestException.new("Error parsing XML: #{ex.message}")
            end
            collection
          else
            nil
          end
        end

        def check_response(response)
          status = response.code.to_i
          case status
          when 200
            response
          when 302
            raise "Unhandled HTTP Redirect"
          when 401
            raise AuthorizationFailure
          when 400, 500
            err = parse_intuit_error(response.body)
            ex = IntuitRequestException.new(err[:message])
            ex.code = err[:code]
            ex.cause = err[:cause]
            raise ex
          else
            raise "HTTP Error Code: #{status}, Msg: #{response.body}"
          end
        end

        def parse_intuit_error(body)
          xml = parse_xml(body)
          error = {:message => "", :code => 0, :cause => ""}

          if xml.at_xpath('html')
            fault = xml.at_xpath("//h1")
          else
            fault = xml.at_xpath("//xmlns:FaultInfo/xmlns:Message")
            error_code = xml.at_xpath("//xmlns:FaultInfo/xmlns:ErrorCode")
            error_cause = xml.at_xpath("//xmlns:FaultInfo/xmlns:Cause")
          end

          if fault
            error[:message] = fault.text
          end
          if error_code
            error[:code] = error_code.text
          end
          if error_cause
            error[:cause] = error_cause.text
          end

          error
        end

        def response_handler
          @_response_handler ||= Quickeebooks::Online::Service::ResponseHandler.new
        end
      end
    end
  end
end
