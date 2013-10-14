require 'uri'

module Quickeebooks
  module Shared
    module Service
      class GetRequestPerformer < GenericRequestPerformer
        def call(url, options = {}, &block)
          request(:get, url, options, &block)
        end

        protected

        def build_full_url(url, params)
          if params
            url + '?' + URI.encode_www_form(params)
          else
            url
          end
        end

        def build_arguments(body, headers)
          [headers]
        end
      end
    end
  end
end
