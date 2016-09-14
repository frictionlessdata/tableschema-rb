module JsonTableSchema
  module Types
    class Null < Base

      def name
        'null'
      end

      def supported_constraints
        [
          'required',
          'pattern',
          'enum',
        ]
      end

      def type
        ::NilClass
      end

      def null_values
        ['null', 'none', 'nil', 'nan', '-', '']
      end

      def cast_default(value)
        if value.is_a?(type)
          return value
        elsif null_values.include?(value.to_s.downcase)
          nil
        else
          raise JsonTableSchema::InvalidCast.new("#{value} is not a #{name}")
        end
      end

    end
  end
end
