module Quickeebooks
  module Shared
    module Service
      class Base
        XML_NS = %{xmlns:ns2="http://www.intuit.com/sb/cdm/qbo" xmlns="http://www.intuit.com/sb/cdm/v2" xmlns:ns3="http://www.intuit.com/sb/cdm"}

        attr_accessor :base_uri, :realm_id, :oauth

        def initialize(oauth_access_token = nil, realm_id = nil)
          if oauth_access_token && realm_id
            msg = "#{self.class} - "
            msg += "This version of the constructor is deprecated. "
            msg += "Use the no-arg constructor and set the AccessToken (access_token=) and the RealmID (realm_id=) using the setters."
            warn(msg)

            self.access_token = oauth_access_token
            self.realm_id = realm_id
          end
        end

        def access_token=(token)
          @oauth = token
        end

        def realm_id=(realm_id)
          @realm_id = realm_id
        end

        def url_for_base(raw)
          "#{self.class.base_url}/#{raw}/v2/#{@realm_id}"
        end

        def on_request(&block)
          @on_request = block
        end

        private

        def valid_xml_document(xml)
          %Q{<?xml version="1.0" encoding="utf-8"?>\n#{xml.strip}}
        end

        def do_http_post(url, body = "", params = {}, headers = {}) # throws IntuitRequestException
          url = add_query_string_to_url(url, params)
          do_http(:post, url, body, headers)
        end

        def do_http_get(url, params = {}, headers = {}) # throws IntuitRequestException
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
          # OAuth::Consumer#request accepts a block;
          # OAuth::ConsumerToken#request does not
          extra_arguments = []
          if [:post, :put].include?(method)
            extra_arguments << body
          end
          extra_arguments << headers
          response = @oauth.consumer.request(method, url, @oauth, {}, *extra_arguments) do |req|
            request = Request.new(req)
            request.uri = url
          end

          fire_on_request(request, response)

          check_response(response)
        end

        def fire_on_request(request, response)
          if @on_request
            @on_request.call(request, response)
          end
        end
      end
    end
  end
end
