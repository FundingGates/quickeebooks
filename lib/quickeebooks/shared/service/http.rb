module Quickeebooks
  module Shared
    module Service
      class Http
        def initialize(service, response_handler)
          self.service = service
          self.response_handler = response_handler
        end

        def get(url, options = {}, &block)
          request(GetRequestPerformer)
        end

        def post(url, options = {}, &block)
          request(PostRequestPerformer)
        end

        private

        def request(performer_class, &block)
          performer = performer_class.new(service, response_handler)
          performer.call(url, options, &block).tap do |response|
            response_handler.call(response)
          end
        end
      end
    end
  end
end
