module TableSchema
  class Constraints
    module Minimum

      def check_minimum
        if @value < parse_constraint(@constraints[:minimum])
          raise TableSchema::ConstraintError.new("The field `#{@field[:name]}` must not be less than #{@constraints[:minimum]}")
        end
        true
      end

    end
  end
end
