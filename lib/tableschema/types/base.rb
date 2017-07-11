require 'tableschema/defaults'

module TableSchema
  module Types
    class Base
      include TableSchema::Helpers

      def initialize(field)
        @field = field
        set_format
      end

      def cast(value)
        send("cast_#{@format}", value)
      rescue NoMethodError => e
        if e.message.start_with?('undefined method `cast_')
          raise(TableSchema::InvalidFormat.new("The format `#{@format}` is not supported by the type `#{@type}`"))
        else
          raise e
        end
      end

      def test(value)
        cast(value)
        true
      rescue TableSchema::Exception
        false
      end

      private

      def set_format
        if (@field[:format] || '').start_with?('fmt:')
          @format, @format_string = *@field[:format].split(':', 2)
        else
          @format = @field[:format] || TableSchema::DEFAULTS[:format]
        end
      end

    end
  end
end
