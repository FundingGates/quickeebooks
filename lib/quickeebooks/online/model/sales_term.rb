require 'quickeebooks/online/model/intuit_type'
require 'quickeebooks/online/model/id'
require 'quickeebooks/online/model/meta_data'

module Quickeebooks
  module Online
    module Model
      class SalesTerm < Quickeebooks::Online::Model::IntuitType
        include ActiveModel::Validations

        XML_COLLECTION_NODE = 'SalesTerms'
        XML_NODE = "SalesTerm"
        REST_RESOURCE = "sales-term"

        xml_convention :camelcase
        xml_accessor :id,         :from => 'Id',        :as => Quickeebooks::Online::Model::Id
        xml_accessor :sync_token, :from => 'SyncToken', :as => Integer
        xml_accessor :meta_data,  :from => 'MetaData',  :as => Quickeebooks::Online::Model::MetaData
        xml_accessor :name,       :from => 'Name'

        def self.resource_for_collection
          "#{self::REST_RESOURCE}s"
        end

      end
    end
  end
end
