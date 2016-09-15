module JsonTableSchema
  module Types
    class Base

      def initialize(field)
        @field = field
        @required = field['required'] == 'true' || field['required'] == true
        @type = @field['type']
        set_format
      end

      def cast(value)
        return nil if is_null?(value)
        send("cast_#{@format}", value)
      rescue NoMethodError => e
        if e.message.start_with?('undefined method `cast_')
          raise(JsonTableSchema::InvalidFormat.new("The format `#{@format}` is not supported by the type `#{@type}`"))
        else
          raise e
        end
      end

      def set_format
        if @field['format'].start_with?('fmt:')
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
          ['null', 'none', 'nil', 'nan', '-', '', nil]
        end

    end
  end
end
