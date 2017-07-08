require 'tableschema/defaults'

module TableSchema
  module Types
    class Base
      include TableSchema::Helpers


      def initialize(field)
        @field = field
        @constraints = field[:constraints] || {}
        @required = ['true', true].include?(@constraints[:required])
        set_format
      end

      def cast(value, check_constraints: true)
        value = nil if is_null?(value)
        send("cast_#{@format}", value) unless value.nil?
        TableSchema::Constraints.new(@field, value).validate! if check_constraints == true
      rescue NoMethodError => e
        if e.message.start_with?('undefined method `cast_')
          raise(TableSchema::InvalidFormat.new("The format `#{@format}` is not supported by the type `#{@type}`"))
        else
          raise e
        end
      end

      def test(value, check_constraints: true)
        cast(value, check_constraints: check_constraints)
        true
      rescue TableSchema::Exception
        false
      end

      def set_format
        if (@field[:format] || '').start_with?('fmt:')
          @format, @format_string = *@field[:format].split(':', 2)
        else
          @format = @field[:format] || TableSchema::DEFAULTS[:format]
        end
      end

      private

        def is_null?(value)
          @field.missing_values.include?(value)
        end

    end
  end
end
