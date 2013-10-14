module RequestPerformerHelpers
  def build_consumer
    double(request: nil)
  end

  def build_access_token(consumer)
    double(consumer: consumer)
  end

  def build_response_handler
    double(call: nil)
  end
end
