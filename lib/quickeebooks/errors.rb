class IntuitRequestException < Exception
  attr_accessor :code, :cause
end

class AuthorizationFailure < Exception; end
