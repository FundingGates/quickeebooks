require 'logger'

module Quickeebooks
  module Logging
    class LogFormatter
      def initialize(object)
        @context_class = object.is_a?(Class) ? object : object.class
      end

      def call(severity, time, program_name, message)
        "time=%s severity=%s class=%s message=%s\n" % [
          time.strftime("%Y-%m-%d %H:%M:%S").inspect,
          severity.to_s.inspect,
          @context_class.to_s.inspect,
          message.gsub("\n", "\r").inspect
        ]
      end
    end

    module ClassMethods
      def logger
        @logger ||= Logger.new(Quickeebooks.log_to).tap do |logger|
          logger.formatter = Quickeebooks.log_formatter_class.new(self)
          logger.level = Quickeebooks.log_level
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def logger
      self.class.logger
    end
  end

  extend Logging::ClassMethods

  class << self
    attr_accessor :log_to
    attr_accessor :log_formatter_class
    attr_accessor :log_level
  end

  self.log_to = $stdout
  self.log_formatter_class = Logging::LogFormatter
  self.log_level = Logger::INFO
end
