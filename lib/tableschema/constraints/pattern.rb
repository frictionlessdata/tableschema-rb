module TableSchema
  class Constraints
    module Pattern

      def check_pattern
        if !@value.to_json.match /#{@constraints['pattern']}/
          raise TableSchema::ConstraintError.new("The value for the field `#{@field['name']}` must match the pattern")
        end
        true
      end

    end
  end
end
