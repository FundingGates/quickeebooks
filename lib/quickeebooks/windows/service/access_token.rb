require 'quickeebooks/shared/service/access_token'

module Quickeebooks
  module Windows
    module Service
      class AccessToken < Base
        include Quickeebooks::Shared::Service::AccessToken
      end
    end
  end
end
