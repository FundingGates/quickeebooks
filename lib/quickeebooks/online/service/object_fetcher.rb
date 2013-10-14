module Quickeebooks
  module Online
    module Service
      class ObjectFetcher
        def initialize(service)
          self.service = service
        end

        def call(model_class, options = {})
          response = http.get(service.class.resource_url, options)
          xml = response.parsed_body
          element = xml.at_xpath("//xmlns:#{model_class.node_name}")
          model_class.from_xml(element)
        end

        private

        attr_accessor :service

        extend Forwardable
        def_delegators :service, :http
      end
    end
  end
end
