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
        value = convert_to_boolean(value)
        raise JsonTableSchema::InvalidCast.new("#{value} is not a #{name}") if value.nil?
        value
      end

    end
  end
end
