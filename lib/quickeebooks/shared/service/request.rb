require 'delegate'

module Quickeebooks
  module Shared
    module Service
      class Request < SimpleDelegator
        attr_reader :request
        attr_accessor :uri

        def initialize(request)
          super(request)
          @request = request
        end

        def method
          request.method
        end
      end
    end
  end
end
