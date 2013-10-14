require 'forwardable'
require 'uri'

module Quickeebooks
  module Shared
    module Service
      class GenericRequestPerformer
        def initialize(service)
          self.service = service
        end

        protected

        def request(method, url, options)
          params = options[:params]
          headers = options.fetch(:headers, {}).merge('Content-Type' => 'application/xml')
          body = options.fetch(:body, "")

          full_url = build_full_url(url, params)
          arguments = build_arguments(body, headers)

          request, response = make_wrapped_request_and_response(method, full_url, arguments)
          yield request, response if block_given?
          response
        end

        private

        attr_accessor :service

        def make_wrapped_request_and_response(method, url, arguments)
          request = nil
          wrapped_response = service.request(method, url, *arguments) do |wrapped_request|
            request = Quickeebooks::Shared::Service::Request.new(wrapped_request)
            request.uri = url
          end
          response = Quickeebooks::Shared::Service::Response.new(wrapped_response)
          [request, response]
        end
      end
    end
  end
end
