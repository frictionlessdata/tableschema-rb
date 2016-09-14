module JsonTableSchema
  module Types
    class Base

      def initialize(field)
        @field = field
        @type = @field['type']
        @format = @field['format'] || 'default'
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

    end
  end
end
