module Quickeebooks
  module Shared
    module Service
      class PostRequestPerformer < GenericRequestPerformer
        def call(url, options = {}, &block)
          request(:post, url, options, &block)
        end

        protected

        def build_full_url(url, params)
          url
        end

        def build_arguments(body, headers)
          [body, headers]
        end
      end
    end
  end
end
