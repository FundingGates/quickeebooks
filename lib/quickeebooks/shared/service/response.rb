require 'delegate'

module Quickeebooks
  class Response < SimpleDelegator
    attr_reader :response, :parsed_body

    def initialize(response)
      super(response)
      @response = response
    end

    def parsed_body
      @parsed_body ||= Nokogiri::XML.parse(body)
    end

    def status
      code.to_i
    end
  end
end
