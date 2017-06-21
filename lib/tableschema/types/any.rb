module TableSchema
  module Types
    class Any < Base

      def name
        'any'
      end

      def self.supported_constraints
        [
          'required',
          'pattern',
          'enum'
        ]
      end

      def cast_default(value)
        value
      end

    end
  end
end
