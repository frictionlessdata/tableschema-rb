module JsonTableSchema
  class Constraints
    module MinLength

      def check_min_length
        if @value.to_s.length < @constraints['minLength'].to_i
          raise JsonTableSchema::ConstraintError.new("The field `#{@field['name']}` must have a minimum length of #{@constraints['minLength']}")
        end
        true
      end

    end
  end
end
