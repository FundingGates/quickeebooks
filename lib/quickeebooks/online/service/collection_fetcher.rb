module Quickeebooks
  module Online
    module Service
      class CollectionFetcher
        def initialize(model_class, service_class, http)
          self.model_class = model_class
          self.service_class = service_class
          self.http = http
        end

        def call(options = {})
          page = options.fetch(:page, 1)
          per_page = options.fetch(:per_page, 20)
          url = service_class.collection_url

          body = {
            'PageNum' => page,
            'ResultsPerPage' => per_page
          }
          if options[:filters]
            body['Filter'] = options[:filters].join(' :AND: ')
          end
          if options[:sort]
            body['Sort'] = options[:sort]
          end

          response = http.post(url, body: body)
          xml = response.parsed_body

          Quickeebooks::Collection.new.tap do |collection|
            collection.entries = xml.xpath("//qbo:SearchResults/qbo:CdmCollections/xmlns:#{model_class.node_name}").map do |element|
              model_class.from_xml(element)
            end
            collection.count = xml.xpath("//qbo:SearchResults/qbo:Count")[0].text.to_i
            collection.current_page = xml.xpath("//qbo:SearchResults/qbo:CurrentPage")[0].text.to_i
          end
        end

        private

        attr_accessor :model_class, :service_class, :http
      end
    end
  end
end
