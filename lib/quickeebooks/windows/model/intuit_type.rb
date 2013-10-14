module Quickeebooks
  module Windows
    module Model
      class IntuitType
        include ROXML

        def self.node_name
          self::XML_NODE
        end

        private

        def log(msg)
          Quickeebooks.logger.info(msg)
          Quickeebooks.logger.flush if Quickeebooks.logger.respond_to?(:flush)
        end

      end
    end
  end
end
