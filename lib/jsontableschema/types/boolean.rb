# Hack to check against one type from http://stackoverflow.com/a/3028378/452684
# because Ruby doesn't have a single boolean class
module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

module JsonTableSchema
  module Types
    class Boolean < Base

      def name
        'boolean'
      end

      def supported_constraints
        [
          'required',
          'pattern',
          'enum',
        ]
      end

      def type
        ::Boolean
      end

      def true_values
        ['yes', 'y', 'true', 't', '1']
      end

      def false_values
        ['no', 'n', 'false', 'f', '0']
      end

      def cast_default(value)
        if value.is_a?(type)
          return value
        elsif true_values.include?(value.to_s.downcase)
          true
        elsif false_values.include?(value.to_s.downcase)
          false
        else
          raise JsonTableSchema::InvalidCast.new("#{value} is not a #{name}")
        end
      end

    end
  end
end
