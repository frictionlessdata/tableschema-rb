module TableSchema
  class Constraints
    module Enum

      def check_enum
        unless parsed_enum.include?(@value)
          raise TableSchema::ConstraintError.new("The value for the field `#{@field[:name]}` must be in the enum array")
        end
        true
      end

      def parsed_enum
        @constraints[:enum].map{ |value| @field.cast_type(value) }
      end

    end
  end
end
