module TableSchema
  module Types
    class YearMonth < Base

      def name
        'yearmonth'
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
        ::Hash
      end

      def cast_default(value)
        value = array_to_yearmonth_string(value) if value.class == ::Array
        cast = ::Date._strptime(value, '%Y-%m')
        unless cast.nil? || cast.include?(:leftover)
          array_to_yearmonth(cast.values)
        else
          raise TableSchema::InvalidYearMonthType.new("#{value} is not a valid yearmonth")
        end
      end

      private

        def array_to_yearmonth(value_array)
          {
            year: value_array[0],
            month: value_array[1],
          }.freeze
        end

        def array_to_yearmonth_string(value)
          if value.length != 2
            raise TableSchema::InvalidYearMonthType.new("#{value} is not a valid yearmonth")
          end
          "#{value[0]}-#{value[1]}"
        end

    end
  end
end
