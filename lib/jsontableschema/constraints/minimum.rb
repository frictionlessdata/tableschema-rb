module JsonTableSchema
  class Constraints
    module Minimum

      def check_minimum
        if @value < parse_constraint(@constraints['minimum'])
          raise JsonTableSchema::ConstraintError.new("The field `#{@field['name']}` must not be less than #{@constraints['minimum']}")
        end
        true
      end

    end
  end
end
