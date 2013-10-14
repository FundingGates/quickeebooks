require 'forwardable'
require 'uri'

module Quickeebooks
  module Shared
    module Service
      class GenericRequestPerformer
        def initialize(access_token, response_handler)
          self.access_token = access_token
          self.response_handler = response_handler
        end

        protected

        def request(method, url, options)
          params = options[:params]
          headers = options.fetch(:headers, {}).merge('Content-Type' => 'application/xml')
          body = options.fetch(:body, "")

          full_url = build_full_url(url, params)
          arguments = build_arguments(body, headers)

          request, response = make_request(method, full_url, arguments)
          yield request, response if block_given?
          response_handler.call(response)
          response
        end

        private

        attr_accessor :access_token, :response_handler, :method, :url, :params,
          :headers, :body

        extend Forwardable
        def_delegators :access_token, :consumer

        def make_request(method, url, arguments)
          request = nil
          wrapped_response = consumer.request(method, url, access_token, {}, *arguments) do |wrapped_request|
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
