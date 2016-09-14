module JsonTableSchema
  module Types
    class Base

      def initialize(field)
        @field = field
        @type = @field['type']
        set_format
      end

      def cast(value)
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
          @format, @format_string = *@field['format'].split(':')
        else
          @format = @field['format'] || 'default'
        end
      end

    end
  end
end
