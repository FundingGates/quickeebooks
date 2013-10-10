require 'quickeebooks/windows/service/base'

module Quickeebooks
  module Windows
    module Service
      class CompanyMetaData < Base
        def load
          model = Quickeebooks::Windows::Model::CompanyMetaData
          fetch_object(model, url_for_resource(model::REST_RESOURCE))
        end
      end
    end
  end
end
