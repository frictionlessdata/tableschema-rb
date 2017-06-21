module TableSchema
  module Types
    class Base
      include TableSchema::Helpers


      def initialize(field)
        @field = field
        @constraints = field['constraints'] || {}
        @required = ['true', true].include?(@constraints['required'])
        @type = @field['type']
        set_format
      end

      def cast(value, skip_constraints = false)
        TableSchema::Constraints.new(@field, value).validate! unless skip_constraints
        return nil if is_null?(value)
        send("cast_#{@format}", value)
      rescue NoMethodError => e
        if e.message.start_with?('undefined method `cast_')
          raise(TableSchema::InvalidFormat.new("The format `#{@format}` is not supported by the type `#{@type}`"))
        else
          raise e
        end
      end

      def test(value)
        cast(value, true)
        true
      rescue TableSchema::Exception
        false
      end

      def set_format
        if (@field['format'] || '').start_with?('fmt:')
          @format, @format_string = *@field['format'].split(':', 2)
        else
          @format = @field['format'] || 'default'
        end
      end

      private

        def is_null?(value)
          null_values.include?(value) && @required == false
        end

        def null_values
          ['null', 'none', 'nil', 'nan', '-', '']
        end

    end
  end
end
