require 'quickeebooks/online/service/base'
require 'quickeebooks/online/model/sales_term'
require 'nokogiri'

module Quickeebooks
  module Online
    module Service
      class SalesTerm < Base
        def fetch_by_id(id, idDomain = 'QB', options = {})
          url = "#{url_for_resource(Quickeebooks::Online::Model::SalesTerm::REST_RESOURCE)}/#{id}"
          fetch_object(Quickeebooks::Online::Model::SalesTerm, url, { :idDomain => idDomain })
        end
      end
    end
  end
end
