module JsonTableSchema
  module Types
    class Integer < Base

      def name
        'integer'
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
        ::Integer
      end

      def cast_default(value)
        if value.is_a?(type)
          value
        else
          Integer(value)
        end
      rescue ArgumentError
        raise JsonTableSchema::InvalidCast.new("#{value} is not a #{name}")
      end

    end
  end
end
