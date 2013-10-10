module Quickeebooks
  module Shared
    module Service
      class Base
        def on_request(&block)
          @on_request = block
        end

        private

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
