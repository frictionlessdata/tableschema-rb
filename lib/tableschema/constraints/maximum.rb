module TableSchema
  class Constraints
    module Maximum

      def check_maximum
        if @field.type == 'yearmonth'
          valid = Date.new(@value[:year], @value[:month]) <= Date.new(parsed_maximum[:year], parsed_maximum[:month])
        else
          valid = @value <= parsed_maximum
        end

        unless valid
          raise TableSchema::ConstraintError.new("The field `#{@field[:name]}` must not be more than #{@constraints[:maximum]}")
        end
        true
      end

      def parsed_maximum
        @field.cast_value(@constraints[:maximum], check_constraints: false)
      end

    end
  end
end
