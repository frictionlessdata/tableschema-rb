module TableSchema
  module Types
    class Year < Base

      def name
        'year'
      end

      def self.supported_constraints
        [
          'required',
          'enum',
          'minimum',
          'maximum',
        ]
      end

      def type
        ::Integer
      end

      def cast_default(value)
        cast = ::Date._strptime(value.to_s, '%Y')
        unless cast.nil? || cast.include?(:leftover)
          cast[:year]
        else
          raise TableSchema::InvalidYearType.new("#{value} is not a valid year")
        end
      end

    end
  end
end
