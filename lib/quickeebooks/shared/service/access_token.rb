module Quickeebooks
  module Shared
    module Service
      module AccessToken
        # See https://developer.intuit.com/docs/0025_quickbooksapi/0060_auth_auth/0020_reconnect_api
        def reconnect
          response = do_http_get("https://appcenter.intuit.com/api/v1/Connection/Reconnect")
          if response && response.code.to_i == 200
            Quickeebooks::Shared::Service::AccessTokenResponse.from_xml(response.body)
          else
            nil
          end
        end

        # See https://developer.intuit.com/docs/0025_quickbooksapi/0060_auth_auth/0015_disconnect_api
        def disconnect
          response = do_http_get("https://appcenter.intuit.com/api/v1/Connection/Disconnect")
          if response && response.code.to_i == 200
            Quickeebooks::Shared::Service::AccessTokenResponse.from_xml(response.body)
          else
            nil
          end
        end
      end
    end
  end
end
