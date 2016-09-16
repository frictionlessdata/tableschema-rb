module JsonTableSchema
  class Constraints
    module Pattern

      def check_pattern
        if !@value.to_json.match /#{@constraints['pattern']}/
          raise JsonTableSchema::ConstraintError.new("The value for the field `#{@field['name']}` must match the pattern")
        end
        true
      end

    end
  end
end
