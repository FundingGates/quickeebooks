module Quickeebooks
  module Shared
    module Service
      class AccessTokenResponse
        include ROXML

        xml_convention :camelcase
        xml_accessor :error_code
        xml_accessor :error_message
        xml_accessor :token,  :from => 'OAuthToken'
        xml_accessor :secret, :from => 'OAuthTokenSecret'

        def error?
          error_code.to_i != 0
        end
      end
    end
  end
end
