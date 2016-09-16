module JsonTableSchema
  class Constraints
    module MinLength

      def check_min_length
        return if @value.nil?
        if @value.length < @constraints['minLength'].to_i
          raise JsonTableSchema::ConstraintError.new("The field `#{@field['name']}` must have a minimum length of #{@constraints['minLength']}")
        end
        true
      end

    end
  end
end
