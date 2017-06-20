module TableSchema
  class Constraints
    module MaxLength

      def check_max_length
        return if @value.nil?
        if @value.length > @constraints['maxLength'].to_i
          raise TableSchema::ConstraintError.new("The field `#{@field['name']}` must have a maximum length of #{@constraints['maxLength']}")
        end
        true
      end

    end
  end
end
