shared_examples_for 'RequestPerformer#call' do
  include RequestPerformerHelpers

  it "calls Oauth::Consumer#request with the URL, access token, and a default content type" do
    consumer = build_consumer
    access_token = build_access_token(consumer)
    response_handler = build_response_handler
    url = 'http://foo.com'

    http = described_class.new(access_token, response_handler)
    http.call(url)

    expect(consumer).to have_received(:request) do |_, passed_url, passed_access_token, _, passed_headers|
      expect(passed_url).to eq url
      expect(passed_access_token).to eq access_token
      expect(passed_headers).to eq('Content-Type' => 'application/xml')
    end
  end

  it "fires a provided callback with the Request and Response objects" do
    consumer = build_consumer.tap do |consumer|
      allow(consumer).to receive(:request).and_yield(:request).and_return(:response)
    end
    access_token = build_access_token(consumer)
    response_handler = build_response_handler

    http = described_class.new(access_token, response_handler)
    request, response = nil
    http.call('http://it.doesnt.matter.com') do |req, res|
      request = req
      response = res
    end
    expect(request).not_to equal :request
    expect(request).to eq :request
    expect(response).not_to equal :response
    expect(response).to eq :response
  end

  it "calls the ResponseHandler with the Response object" do
    consumer = build_consumer.tap do |consumer|
      allow(consumer).to receive(:request).and_yield(:request).and_return(:response)
    end
    access_token = build_access_token(consumer)
    response_handler = build_response_handler

    http = described_class.new(access_token, response_handler)
    http.call('http://foo.com')

    expect(response_handler).to have_received(:call) do |response|
      expect(response).not_to equal :response
      expect(response).to eq :response
    end
  end

  it "returns the Response object" do
    consumer = build_consumer.tap do |consumer|
      allow(consumer).to receive(:request).and_yield(:request).and_return(:response)
    end
    access_token = build_access_token(consumer)
    response_handler = build_response_handler

    http = described_class.new(access_token, response_handler)
    response = http.call('http://it.doesnt.matter.com')
    expect(response).to eq :response
  end
end
