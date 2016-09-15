module JsonTableSchema
  module Types
    class Time < Base

      def name
        'time'
      end

      def supported_constraints
        [
          'required',
          'pattern',
          'enum',
          'minimum',
          'maximum',
        ]
      end

      def type
        ::Tod::TimeOfDay
      end

      def iso8601
        '%H:%M:%S'
      end

      def cast_default(value)
        @format_string = iso8601
        cast_fmt(value)
      end

      def cast_any(value)
        return value if value.is_a?(type)

        begin
          return ::Tod::TimeOfDay.parse(value)
        rescue ArgumentError
          raise JsonTableSchema::InvalidTimeType.new("#{value} is not a valid time")
        end
      end

      def cast_fmt(value)
        return value if value.is_a?(type)

        begin
          time = ::Time.strptime(value, @format_string)
          return time.to_time_of_day
        rescue ArgumentError, TypeError
          raise JsonTableSchema::InvalidTimeType.new("#{value} is not a valid time")
        end
      end

    end
  end
end
