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
      rescue NoMethodError
        raise(JsonTableSchema::InvalidFormat.new("The format `#{@format}` is not supported by the type `#{@type}`"))
      end

    end
  end
end
