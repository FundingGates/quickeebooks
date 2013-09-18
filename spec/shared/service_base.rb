require 'spec_helper'

shared_examples_for 'Quickeebooks::Shared::Service::ServiceBase' do
  context 'logging' do
    it "occurs for each request" do
      base_uri = 'http://oauth.example.com'
      method_name = :fetch_something
      request_method = :get
      path = '/some_path'
      body = 'this is the body'
      status = 200

      url = base_uri + path

      FakeWeb.register_uri(:get, url, body: body, status: status)

      consumer = build_oauth_consumer(site: base_uri)
      access_token = build_oauth_access_token(consumer: consumer)
      service = build_service_base(
        access_token: access_token,
        methods: { method_name => [request_method, url] }
      )
      callback = lambda {}
      callback.should_receive(:call) do |request, response|
        request_headers = request.to_hash
        request.method.should eq request_method.to_s.upcase
        request.uri.should eq url
        request_headers['content-type'].should include 'application/xml'
        request.body.to_s.should be_empty

        response_headers = response.to_hash
        response.code.should eq status.to_s
        response_headers.should be_empty
        response.body.should eq body
      end
      service.on_request(&callback)
      service.fetch_something
    end

    def build_service_base(options = {})
      access_token = options.fetch(:access_token) { build_oauth_access_token }
      methods = options[:methods] || {}
      build_service_base_subclass(methods).new.tap do |service_base|
        service_base.access_token = access_token
      end
    end

    def build_service_base_subclass(methods = {})
      klass = Class.new(described_class)
      methods.each do |method_name, (request_method, url)|
        klass.__send__(:define_method, method_name) do
          do_http(request_method, url, "", {})
        end
      end
      klass
    end

    def build_oauth_access_token(options = {})
      consumer = options.fetch(:consumer) { build_oauth_consumer }
      OAuth::AccessToken.new(consumer, 'key', 'secret')
    end

    def build_oauth_consumer(overrides = {})
      defaults = {
        site: 'http://oauth.example.com',
        request_token_path: '/get_request_token',
        authorize_path: '/authorize',
        access_token_path: '/get_access_token'
      }
      options = defaults.merge(overrides)
      OAuth::Consumer.new('key', 'secret', options)
    end
  end
end
