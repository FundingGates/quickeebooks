require 'logger'

module Quickeebooks
  module Logging
    module ClassMethods
      def logger
        @logger || Quickeebooks.logger
      end

      def logger=(logger)
        @logger = logger
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def logger
      self.class.logger
    end
  end

  class << self
    attr_accessor :logger
  end

  self.logger = Logger.new($stdout).tap do |logger|
    logger.level = Logger::INFO
  end
end
