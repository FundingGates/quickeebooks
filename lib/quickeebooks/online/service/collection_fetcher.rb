module Quickeebooks
  module Online
    module Service
      class CollectionFetcher
        def initialize(service)
          self.service = service
        end

        def call(model_class, options = {})
          page = options.fetch(:page, 1)
          per_page = options.fetch(:per_page, 20)
          url = service.class.collection_url

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
            results = xml.at_xpath('//qbo:SearchResults')
            collection.entries = results.xpath("//qbo:CdmCollections/xmlns:#{model_class.node_name}").map do |element|
              model_class.from_xml(element)
            end
            collection.count = results.at_xpath("//qbo:Count").text.to_i
            collection.current_page = results.at_xpath("//qbo:CurrentPage").text.to_i
          end
        end

        private

        attr_accessor :service

        extend Forwardable
        def_delegators :service, :http
      end
    end
  end
end
