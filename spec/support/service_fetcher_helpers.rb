module ServiceFetcherHelpers
  def build_model_class(options = {}, &block)
    node_name = options.fetch(:node_name, 'Foo')

    Class.new(Quickeebooks::Online::Model::IntuitType, &block).tap do |model_class|
      allow(model_class).to receive(:node_name).and_return(node_name)
    end
  end

  def build_service(options = {}, &block)
    resource_url = options.fetch(:resource_url, 'http://foo.com/foo')
    collection_url = options.fetch(:collection_url, 'http://foo.com/foos')
    http = options.fetch(:http) { build_http }

    service_class = Class.new(Quickeebooks::Shared::Service::Base, &block).tap do |service_class|
      allow(service_class).to receive(:resource_url).and_return(resource_url)
      allow(service_class).to receive(:collection_url).and_return(collection_url)
    end

    service_class.new.tap do |service|
      allow(service).to receive(:http).and_return(http)
    end
  end

  def build_http(*args)
    http = double
    if args.any?
      method, response = *args
      allow(http).to receive(method).and_return(response)
    end
    http
  end

  def build_request_performer
    double(call: nil)
  end

  def build_response_from_body(body)
    double(
      body: body,
      parsed_body: Nokogiri::XML.parse(body)
    )
  end

  def build_response_from_model_class(model_class)
    body = build_body_from_model_class(model_class)
    build_response_from_body(body)
  end

  def build_body_from_model_class(model_class, options = {})
    build_body(model_class.node_name, options)
  end
end
