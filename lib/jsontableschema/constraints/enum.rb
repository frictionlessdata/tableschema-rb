module JsonTableSchema
  class Constraints
    module Enum

      def check_enum
        order_arrays!
        if !parse_constraint(@constraints['enum']).include?(@value)
          raise JsonTableSchema::ConstraintError.new("The value for the field `#{@field['name']}` must be in the enum array")
        end
        true
      end

      def order_arrays!
        if @constraints['enum'].is_a?(Array) && @value.is_a?(Array)
          @constraints['enum'].sort!
          @value.sort!
        end
      end

    end
  end
end
