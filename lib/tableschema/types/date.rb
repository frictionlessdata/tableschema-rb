module TableSchema
  module Types
    class Date < Base

      def name
        'date'
      end

      def self.supported_constraints
        [
          'required',
          'unique',
          'pattern',
          'enum',
          'minimum',
          'maximum',
        ]
      end

      def type
        ::Date
      end

      def iso8601
        '%Y-%m-%d'
      end

      def cast_default(value)
        @format_string = iso8601
        cast_fmt(value)
      end

      def cast_any(value)
        return value if value.is_a?(type)

        date = ::Date._parse(value)
        if date.values.count == 3
          ::Date.parse(value)
        else
          raise TableSchema::InvalidDateType.new("#{value} is not a valid date")
        end
      end

      def cast_fmt(value)
        return value if value.is_a?(type)

        begin
          return ::Date.strptime(value, @format_string)
        rescue ArgumentError
          raise TableSchema::InvalidDateType.new("#{value} is not a valid date")
        end
      end


    end
  end
end
