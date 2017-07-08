module TableSchema
  class Constraints
    module Pattern

      def check_pattern
        constraint = lambda { |value| value.match(/#{@constraints[:pattern]}/) }
        if @field.type == 'yearmonth'
          valid = constraint.call(Date.new(@value[:year], @value[:month]).strftime('%Y-%m'))
        else
          valid = constraint.call(@value.to_json)
        end

        unless valid
          raise TableSchema::ConstraintError.new("The value for the field `#{@field[:name]}` must match the pattern")
        end
        true
      end

    end
  end
end
