require 'spec_helper'

describe Quickeebooks::Online::Service::ResponseHandler do
  let(:fake_response_class) do
    Class.new do
      attr_accessor :code, :body, :parsed_body, :headers

      def initialize(code, body, parsed_body, headers)
        self.code = code
        self.body = body
        self.parsed_body = parsed_body
        self.headers = headers
      end
    end
  end

  describe '#call' do
    context 'when the response code is 200' do
      it "returns the response object" do
        response = build_response(200)
        handler = described_class.new(response)
        returned_response = handler.call
        expect(returned_response).to equal response
      end
    end

    context 'when the response code is 404' do
      it "returns nil" do
        response = build_response(404)
        handler = described_class.new(response)
        result = handler.call
        expect(result).to eq nil
      end
    end

    context 'when the response code is anything else' do
      context 'when the response is in a simple HTML format' do
        it "handles a 503 by raising a ServerError" do
          message = 'Service Temporarily Unavailable'
          description = 'The server is temporarily unable to service your request'
          response = build_simple_html_response(503, message, description)
          handler = described_class.new(response)

          handling_error_response(handler) do |error|
            expect(error).to be_a(Quickeebooks::Online::Service::ServerError)
            expect(error.message).to eq message
            expect(error.data[:description]).to eq description
            expect(error.response_code).to eq 503
            expect(error.response_body).to eq response.body
          end
        end

        it "handles any other response code by raising a RequestError" do
          message = 'Request Timeout'
          description = 'The request timed out'
          response = build_simple_html_response(408, message, description)
          handler = described_class.new(response)

          handling_error_response(handler) do |error|
            expect(error).to be_a(Quickeebooks::Online::Service::RequestError)
            expect(error.message).to eq message
            expect(error.data[:description]).to eq description
            expect(error.response_code).to eq 408
            expect(error.response_body).to eq response.body
          end
        end
      end

      context 'when the response is in a more complex HTML format' do
        it "handles a 400 by raising a InvalidRequestError" do
          error_code = '007001'
          message = 'No destination found for given partition key'
          description = 'The request sent by the client was syntactically incorrect'
          response = build_more_complex_html_response(400, error_code, message, description)
          handler = described_class.new(response)

          handling_error_response(handler) do |error|
            expect(error).to be_a(Quickeebooks::Online::Service::RequestError)
            expect(error.message).to eq message
            expect(error.data[:error_code]).to eq error_code
            expect(error.data[:description]).to eq description
            expect(error.response_code).to eq 400
            expect(error.response_body).to eq response.body
          end
        end

        it "handles a 500 by raising a ServerError" do
          error_code = '007006'
          message = 'This company has been marked inactive.'
          description = 'Some other description goes here'
          response = build_more_complex_html_response(500, error_code, message, description)
          handler = described_class.new(response)

          handling_error_response(handler) do |error|
            expect(error).to be_a(Quickeebooks::Online::Service::ServerError)
            expect(error.message).to eq message
            expect(error.data[:error_code]).to eq error_code
            expect(error.data[:description]).to eq description
            expect(error.response_code).to eq 500
            expect(error.response_body).to eq response.body
          end
        end

        it "handles any other response code by raising a RequestError" do
          error_code = '009999'
          message = 'Bad Gateway'
          description = 'Our server just collapsed, sorry about that'
          response = build_more_complex_html_response(502, error_code, message, description)
          handler = described_class.new(response)

          handling_error_response(handler) do |error|
            expect(error).to be_a(Quickeebooks::Online::Service::ServerError)
            expect(error.message).to eq message
            expect(error.data[:error_code]).to eq error_code
            expect(error.data[:description]).to eq description
            expect(error.response_code).to eq 502
            expect(error.response_body).to eq response.body
          end
        end
      end

      context 'when the response is in XML format' do
        it "handles a 400 by raising an InvalidRequestError" do
          message = 'No destination found for given partition key'
          error_code = '400'
          cause = 'CLIENT'
          response = build_xml_response(400, message, error_code, cause)
          handler = described_class.new(response)

          handling_error_response(handler) do |error|
            expect(error).to be_a(Quickeebooks::Online::Service::InvalidRequestError)
            expect(error.message).to eq message
            expect(error.data[:error_code]).to eq error_code
            expect(error.data[:cause]).to eq cause
            expect(error.response_code).to eq 400
            expect(error.response_body).to eq response.body
          end
        end

        it "handles a 401 with a non-empty body by raising an UnauthorizedError including the code and cause" do
          message = 'You must be authorized'
          error_code = '401'
          cause = 'CLIENT'
          response = build_xml_response(401, message, error_code, cause)
          handler = described_class.new(response)

          handling_error_response(handler) do |error|
            expect(error).to be_a(Quickeebooks::Online::Service::UnauthorizedError)
            expect(error.message).to eq message
            expect(error.data[:error_code]).to eq error_code
            expect(error.data[:cause]).to eq cause
            expect(error.response_code).to eq 401
            expect(error.response_body).to eq response.body
          end
        end

        it "handles a 401 with an empty body by raising a plain UnauthorizedError" do
          body = ""
          response = build_response(401, body)
          handler = described_class.new(response)

          handling_error_response(handler) do |error|
            expect(error).to be_a(Quickeebooks::Online::Service::UnauthorizedError)
            expect(error.message).to eq 'Unauthorized Error'
            expect(error.response_code).to eq 401
            expect(error.response_body).to eq body
          end
        end

        it "handles a 500 by raising a ServerError" do
          message = 'General IO error while proxying request'
          error_code = '500'
          cause = 'SERVER'
          response = build_xml_response(500, message, error_code, cause)
          handler = described_class.new(response)

          handling_error_response(handler) do |error|
            expect(error).to be_a(Quickeebooks::Online::Service::ServerError)
            expect(error.message).to eq message
            expect(error.data[:error_code]).to eq error_code
            expect(error.data[:cause]).to eq cause
            expect(error.response_code).to eq 500
            expect(error.response_body).to eq response.body
          end
        end
      end
    end
  end

  def build_response(code, body = "")
    parsed_body = Nokogiri::XML.parse(body)
    fake_response_class.new(code, body, parsed_body, {})
  end

  def handling_error_response(handler)
    error = nil
    begin
      handler.call
    rescue => e
      error = e
      yield e
    end
    expect(error).not_to be_nil
  end

  def build_simple_html_response(response_code, message, description)
    body = <<-EOT
      <html>
        <body>
          <h1>#{message}</h1>
          <p>#{description}</p>
        </body>
      </html>
    EOT
    build_response(response_code, body).tap do |response|
      response.headers['Content-Type'] = 'application/html'
    end
  end

  def build_more_complex_html_response(response_code, error_code, message, description)
    full_message = "message=#{message}; errorCode=#{error_code}; code=#{response_code}"
    body = <<-EOT
      <html>
      <body>
        <h1>HTTP Status #{response_code} - #{full_message}</h1>
        <HR size="1" noshade="noshade"/>
        <p>
          <b>type</b>
          Something goes here
        </p>
        <p>
          <b>message</b>
          <u>#{full_message}</u>
        </p>
        <p>
          <b>description</b>
          <u>#{description} (#{full_message}).</u>
        </p>
        <HR size="1" noshade="noshade"/>
        <h3>JBoss Web/2.1.12.GA-patch-03</h3>
      </body>
      </html>
    EOT
    build_response(response_code, body).tap do |response|
      response.headers['Content-Type'] = 'application/html'
    end
  end

  def build_xml_response(response_code, message, error_code, cause)
    body = <<-EOT
      <FaultInfo xmlns="http://intuit.com/namespace">
        <Message>#{message}</Message>
        <ErrorCode>#{error_code}</ErrorCode>
        <Cause>#{cause}</Cause>
      </FaultInfo>
    EOT
    build_response(response_code, body).tap do |response|
      response.headers['Content-Type'] = 'application/xml'
    end
  end
end
