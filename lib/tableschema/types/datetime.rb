module TableSchema
  module Types
    class DateTime < Base

      def name
        'datetime'
      end

      def self.supported_constraints
        [
          'required',
          'pattern',
          'enum',
          'minimum',
          'maximum'
        ]
      end

      def type
        ::DateTime
      end

      def iso8601
        '%Y-%m-%dT%H:%M:%SZ'
      end

      # raw_formats = ['DD/MM/YYYYThh/mm/ss']
      # py_formats = ['%Y/%m/%dT%H:%M:%S']
      # format_map = dict(zip(raw_formats, py_formats))

      def cast_default(value)
        @format_string = iso8601
        cast_fmt(value)
      end

      def cast_any(value)
        return value if value.is_a?(type)

        begin
          date = ::DateTime._parse(value)
          if date.values.count >= 4
            ::DateTime.parse(value)
          else
            raise TableSchema::InvalidDateTimeType.new("#{value} is not a valid datetime")
          end
        rescue ArgumentError
          raise TableSchema::InvalidDateTimeType.new("#{value} is not a valid datetime")
        end
      end

      def cast_fmt(value)
        return value if value.is_a?(type)

        begin
          return ::DateTime.strptime(value, @format_string)
        rescue ArgumentError
          raise TableSchema::InvalidDateTimeType.new("#{value} is not a valid date")
        end
      end

    end
  end
end
