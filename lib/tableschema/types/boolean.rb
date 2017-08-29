# Hack to check against one type from http://stackoverflow.com/a/3028378/452684
# because Ruby doesn't have a single boolean class
module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

module TableSchema
  module Types
    class Boolean < Base

      def name
        'boolean'
      end

      def self.supported_constraints
        [
          'required',
          'pattern',
          'enum',
        ]
      end

      def type
        ::Boolean
      end

      def cast_default(value)
        true_values = @field.fetch(:trueValues, TableSchema::DEFAULTS[:true_values])
        false_values = @field.fetch(:falseValues, TableSchema::DEFAULTS[:false_values])
        if [true, false].include?(value)
          return value
        elsif true_values.include?(value)
          return true
        elsif false_values.include?(value)
          return false
        else
          raise TableSchema::InvalidCast.new("#{value} is not a #{name}")
        end
      end

    end
  end
end
