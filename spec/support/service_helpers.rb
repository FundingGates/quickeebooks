module ServiceHelpers
  def build_consumer
    OAuth::Consumer.new('key', 'secret')
  end

  def build_access_token
    consumer = build_consumer
    OAuth::AccessToken.new(consumer, 'token', 'secret')
  end

  def fake_realm_id
    '999'
  end
end
