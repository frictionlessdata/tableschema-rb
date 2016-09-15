module JsonTableSchema
  class Constraints
    module Minimum

      def check_minimum
        if @value < parse_constraint(@constraints['minimum'])
          raise JsonTableSchema::ConstraintError.new("The field `#{@field['name']}` must not be less than #{@constraints['minimum']}")
        end
        true
      end

      private

      def parse_constraint(constraint)
        if @value.is_a?(::Integer)
          constraint.to_i
        elsif @value.is_a?(::Tod::TimeOfDay)
          Tod::TimeOfDay.parse(constraint)
        elsif @value.is_a?(::DateTime)
          DateTime.parse(constraint)
        elsif @value.is_a?(::Date)
          Date.parse(constraint)
        end
      end

    end
  end
end
