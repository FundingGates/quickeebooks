module Quickeebooks
  module Online
    module Service
      class RequestError < Quickeebooks::RequestError
        def self.build_from(response, message = nil, data = {})
          error_class = error_class_from(response)
          error_class.new(message).tap do |error|
            error.response_code = response.code
            error.response_body = response.body
            error.data = data
          end
        end

        def self.error_class_from(response)
          case response.code
            when 400        then InvalidRequestError
            when 401        then UnauthorizedError
            when (500..600) then ServerError
            else                 self
          end
        end

        attr_accessor :response_code, :response_body, :data

        def initialize(message)
          message ||= default_message
          super(message)
          self.data = {}
        end

        private

        def default_message
          self.class.to_s.split('::').last.gsub(/([a-z])([A-Z])/) { "#{$1} #{$2}" }
        end
      end

      InvalidRequestError = Class.new(RequestError)
      UnauthorizedError = Class.new(RequestError)
      ServerError = Class.new(RequestError)
    end
  end
end
