module Quickeebooks
  module Online
    module Service
      class ObjectFetcher
        def initialize(model_class, service_class, http)
          self.model_class = model_class
          self.service_class = service_class
          self.http = http
        end

        def call(options = {})
          params = options.fetch(:params, {})
          url = service_class.resource_url
          response = http.get(url, params: params)

          xml = response.parsed_body
          element = xml.at_xpath("//xmlns:#{model_class.node_name}")
          model_class.from_xml(element)
        end

        private

        attr_accessor :model_class, :service_class, :http
      end
    end
  end
end
