module ServiceFetcherHelpers
  def build_model_class(options = {}, &block)
    node_name = options.fetch(:node_name, 'Foo')
    model_class = Class.new(Quickeebooks::Online::Model::IntuitType, &block)
    model_class.stub(node_name: node_name)
    model_class
  end

  def build_service_class(options = {}, &block)
    resource_url = options.fetch(:resource_url, 'http://foo.com/foo')
    collection_url = options.fetch(:collection_url, 'http://foo.com/foos')
    service_class = Class.new(Quickeebooks::Shared::Service::Base, &block)
    service_class.stub(resource_url: resource_url)
    service_class.stub(collection_url: collection_url)
    service_class
  end

  def build_http
    double
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
