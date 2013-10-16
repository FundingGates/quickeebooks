module Quickeebooks
  module Online
    module Service
      # Status code and error messages that QBO returns are documented here:
      # https://developer.intuit.com/docs/0025_quickbooksapi/0050_data_services/v2/0400_quickbooks_online/0300_error_handling/0050_http_status_codes

      class ResponseHandler
        def self.register(handler_class)
          unless sub_handler_classes.include?(handler_class)
            sub_handler_classes << handler_class
          end
        end

        def self.sub_handler_classes
          @_sub_handler_classes ||= []
        end

        def initialize(response)
          self.response = response
        end

        def call
          sub_handler.call
        end

        private

        attr_accessor :response

        def sub_handler
          sub_handlers.find { |handler| handler.matches? }
        end

        def sub_handlers
          @_sub_handlers ||= self.class.sub_handler_classes.map do |handler_class|
            handler_class.new(response)
          end
        end
      end

      class SuccessfulResponseHandler
        ResponseHandler.register(self)

        def initialize(response)
          self.response = response
        end

        def matches?
          response.code == 200
        end

        def call
          response
        end

        private

        attr_accessor :response
      end

      class NotFoundResponseHandler
        ResponseHandler.register(self)

        def initialize(response)
          self.response = response
        end

        def matches?
          response.code == 404
        end

        def call
          nil
        end

        private

        attr_accessor :response
      end

      class MoreComplexHtmlResponseHandler
        ResponseHandler.register(self)

        def initialize(response)
          self.response = response
        end

        def matches?
          response.headers['Content-Type'] == 'application/html' &&
            response_has_hr?
        end

        def call
          raise RequestError.build_from(response, message,
            error_code: error_code,
            description: description
          )
        end

        def response_has_hr?
          (document.at_css('hr') || document.at_css('HR'))
        end

        private

        attr_accessor :response

        def document
          response.parsed_body
        end

        def paragraphs
          document.css('p')
        end

        def full_message_node
          if defined?(@_full_message_node)
            @_full_message_node
          else
            @_full_message_node = begin
              para = paragraphs[1]
              if para
                para.at_css('u')
              end
            end
          end
        end

        def full_message
          if full_message_node
            full_message_node.text
          end
        end

        def data
          if defined?(@_data)
            @_data
          else
            @_data =
              if full_message
                full_message.split(/;[ ]*/).inject({}) do |hash, pair|
                  key, value = pair.split('=', 2)
                  hash[key] = value
                  hash
                end
              end
          end
        end

        def message
          if data
            data['message']
          end
        end

        def error_code
          if data
            data['errorCode']
          end
        end

        def description_node
          para = paragraphs[2]
          if para
            para.at_css('u')
          end
        end

        def description
          if description_node
            description_node.text.sub(/ \([^)]+\).*/, '')
          end
        end
      end

      class SimpleHtmlResponseHandler
        ResponseHandler.register(self)

        def initialize(response)
          self.response = response
          self.more_complex_handler = MoreComplexHtmlResponseHandler.new(response)
        end

        def matches?
          response.headers['Content-Type'] == 'application/html' &&
            !more_complex_handler.response_has_hr?
        end

        def call
          raise RequestError.build_from(response, message,
            description: description
          )
        end

        private

        attr_accessor :response, :more_complex_handler

        def document
          response.parsed_body
        end

        def message_node
          document.at_css('h1')
        end

        def message
          if message_node
            message_node.text
          end
        end

        def description_node
          document.at_css('p')
        end

        def description
          if description_node
            description_node.text
          end
        end
      end

      class XmlResponseHandler
        ResponseHandler.register(self)

        def initialize(response)
          self.response = response
        end

        def matches?
          response.headers['Content-Type'] == 'application/xml'
        end

        def call
          raise RequestError.build_from(response, message,
            error_code: error_code,
            cause: cause
          )
        end

        private

        attr_accessor :response

        def document
          response.parsed_body
        end

        def fault_info_node
          if defined?(@_fault_info_node)
            @_fault_info_node
          else
            @_fault_info_node = document.at_xpath('//xmlns:FaultInfo')
          end
        end

        def message_node
          fault_info_node.at_xpath('//xmlns:Message')
        end

        def message
          if message_node
            message_node.text
          end
        end

        def error_code_node
          fault_info_node.at_xpath('//xmlns:ErrorCode')
        end

        def error_code
          if error_code_node
            error_code_node.text
          end
        end

        def cause_node
          fault_info_node.at_xpath('//xmlns:Cause')
        end

        def cause
          if cause_node
            cause_node.text
          end
        end
      end

      class ErrorResponseHandler
        ResponseHandler.register(self)

        def initialize(response)
          self.response = response
        end

        def matches?
          true
        end

        def call
          raise RequestError.build_from(response)
        end

        private

        attr_accessor :response
      end
    end
  end
end
