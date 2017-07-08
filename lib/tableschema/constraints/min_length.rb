module TableSchema
  class Constraints
    module MinLength

      def check_min_length
        return if @value.nil?
        if @value.length < parsed_min_length
          raise TableSchema::ConstraintError.new("The field `#{@field[:name]}` must have a minimum length of #{@constraints[:minLength]}")
        end
        true
      end

      def parsed_min_length
        @constraints[:minLength].to_i
      end

    end
  end
end
