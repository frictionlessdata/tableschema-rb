module TableSchema
  class Constraints
    module Minimum

      def check_minimum
        if @field.type == 'yearmonth'
          valid = Date.new(@value[:year], @value[:month]) >= Date.new(parsed_minimum[:year], parsed_minimum[:month])
        else
          valid = @value >= parsed_minimum
        end

        unless valid
          raise TableSchema::ConstraintError.new("The field `#{@field[:name]}` must not be less than #{@constraints[:minimum]}")
        end
        true
      end

      def parsed_minimum
        @field.cast_type(@constraints[:minimum])
      end

    end
  end
end
