shared_examples_for 'RequestPerformer#call' do
  include RequestPerformerHelpers

  it "calls Oauth::Consumer#request with the URL, access token, and a default content type" do
    service = build_service
    http_performer = described_class.new(service)
    url = 'http://foo.com'

    http_performer.call(url)

    expect(service).to have_received(:request) do |_, passed_url, passed_access_token, _, passed_headers|
      expect(passed_url).to eq url
      expect(passed_access_token).to eq access_token
      expect(passed_headers).to eq('Content-Type' => 'application/xml')
    end
  end

  it "fires a provided callback with the Request and Response objects" do
    service = build_service.tap do |service|
      allow(service).to receive(:request).and_yield(:request).and_return(:response)
    end
    http_performer = described_class.new(service)
    request, response = nil

    http_performer.call('http://it.doesnt.matter.com') do |req, res|
      request = req
      response = res
    end

    expect(request).not_to equal :request
    expect(request).to eq :request
    expect(response).not_to equal :response
    expect(response).to eq :response
  end

  it "returns the Response object" do
    service = build_service.tap do |service|
      allow(service).to receive(:request).and_yield(:request).and_return(:response)
    end
    http_performer = described_class.new(service)

    response = http_performer.call('http://it.doesnt.matter.com')

    expect(response).to eq :response
  end
end
