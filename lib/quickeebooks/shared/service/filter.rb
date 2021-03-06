module Quickeebooks
  module Shared
    module Service
      class Filter

        DATE_FORMAT = '%Y-%m-%d'
        DATE_TIME_FORMAT = '%Y-%m-%dT%H:%M:%S%Z'

        attr_reader :type
        attr_accessor :field, :value, :escape

        # For Date/Time filtering
        attr_accessor :before, :after

        # For number comparisons
        attr_accessor :gt, :lt, :eq

        def initialize(type, *args)
          @escape = true
          @type = type
          if args.first.is_a?(Hash)
            args.first.each_pair do |key, value|
              instance_variable_set("@#{key}", value)
            end
          end
        end

        def to_s
          case @type.to_sym
          when :date, :datetime
            date_time_to_s
          when :text
            text_to_s
          when :boolean
            boolean_to_s
          when :number
            number_to_s
          else
            raise ArgumentError, "Don't know how to generate a Filter for type #{@type}"
          end
        end

        def to_xml
          case @type.to_sym
          when :date
            date_to_xml
          when :datetime
            date_time_to_xml
          when :text, :number
            text_to_xml
          when :boolean
            boolean_to_xml
          when :filter_set
            filter_set_to_xml
          else
            raise ArgumentError, "Don't know how to generate a Filter for type #{@type}"
          end
        end

        private

        def number_to_s
          clauses = []
          if @eq
            clauses << "#{@field} :EQUALS: #{@eq}"
          end
          if @gt
            clauses << "#{@field} :GreaterThan: #{@gt}"
          end
          if @lt
            clauses << "#{@field} :LessThan: #{@lt}"
          end
          clauses.join(" :AND: ")
        end

        def date_time_to_s
          clauses = []
          if @before
            raise ':before is not a valid DateTime/Time object' unless (@before.is_a?(Time) || @before.is_a?(DateTime))
            clauses << "#{@field} :BEFORE: #{formatted_time(@before)}"
          end
          if @after
            raise ':after is not a valid DateTime/Time object' unless (@after.is_a?(Time) || @after.is_a?(DateTime))
            clauses << "#{@field} :AFTER: #{formatted_time(@after)}"
          end

          if @before.nil? && @after.nil?
            clauses << "#{@field} :EQUALS: #{formatted_time(@value)}"
          end

          clauses.join(" :AND: ")
        end

        def date_to_xml
          raise ':value is not a valid DateTime/Time object' unless (@value.is_a?(Time) || @value.is_a?(DateTime))
          "<#{@field}>#{xml_formatted_date(@value)}</#{field}>"
        end

        def date_time_to_xml
          raise ':value is not a valid DateTime/Time object' unless (@value.is_a?(Time) || @value.is_a?(DateTime))
          "<#{@field}>#{xml_formatted_time(@value)}</#{field}>"
        end

        def text_to_s
          "#{@field} :EQUALS: #{@value}"
        end

        def text_to_xml
          value = @escape ? CGI::escapeHTML(@value.to_s) : @value

          "<#{@field}>#{value}</#{@field}>"
        end

        def boolean_to_s
          "#{@field} :EQUALS: #{@value}"
        end

        def boolean_to_xml
          value = @escape ? CGI::escapeHTML(@value.to_s) : @value

          "<#{@field}>#{value}</#{@field}>"
        end

        def filter_set_to_xml
          unless @value.is_a?(Array) and @value.all? {|item| item.is_a?(self.class) }
            raise ArgumentError, "Given :value must be an array of Filters"
          end

          xml = "<#{@field}>"
          @value.each do |filter|
            xml << filter.to_xml
          end
          xml << "</#{@field}>"

          xml
        end

        def xml_formatted_date(time)
          time.strftime(DATE_FORMAT)
        end

        def xml_formatted_time(time)
          time.utc.iso8601(1)
        end

        def formatted_time(time)
          if time.is_a?(Date)
            time.strftime(DATE_FORMAT)
          elsif time.respond_to?(:strftime) # catch any other Time-like object
            time.strftime(DATE_TIME_FORMAT)
          end
        end
      end
    end
  end
end
