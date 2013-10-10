require 'quickeebooks/windows/service/base'

module Quickeebooks
  module Windows
    module Service
      class CustomerMsg < Base
        def list(filters = [], page = 1, per_page = 20, sort = nil, options = {})
          fetch_collection(Quickeebooks::Windows::Model::CustomerMsg, nil, filters, page, per_page, sort, options)
        end
      end
    end
  end
end
