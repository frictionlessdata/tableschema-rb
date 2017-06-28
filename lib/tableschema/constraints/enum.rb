module TableSchema
  class Constraints
    module Enum

      def check_enum
        if !parse_constraint(@constraints[:enum]).include?(@value)
          raise TableSchema::ConstraintError.new("The value for the field `#{@field[:name]}` must be in the enum array")
        end
        true
      end

    end
  end
end
