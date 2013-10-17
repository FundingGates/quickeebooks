require 'quickeebooks/online/service/service_base'
require 'quickeebooks/online/model/sales_term'
require 'nokogiri'

module Quickeebooks
  module Online
    module Service
      class SalesTerm < ServiceBase
        def fetch_by_id(id, idDomain = 'QB', options = {})
          url = "#{url_for_resource(Quickeebooks::Online::Model::SalesTerm::REST_RESOURCE)}/#{id}"
          fetch_object(Quickeebooks::Online::Model::SalesTerm, url, { :idDomain => idDomain })
        end

        private

        def fetch_object(model, url, params = {}, options = {})
          raise ArgumentError, "missing model to instantiate" if model.nil?
          response = do_http_get(url, params, {'Content-Type' => 'text/xml'})

          xml = parse_xml(response.body)
          begin
            element = xml.at_xpath("//xmlns:#{model::XML_NODE}")
          rescue Nokogiri::XML::XPath::SyntaxError => ex
            raise IntuitRequestException.new("Error parsing XML: #{ex.message}\nHTTP Response: (#{response.code}) #{response.body}")
          end
          model.from_xml(element)
        end
      end
    end
  end
end
