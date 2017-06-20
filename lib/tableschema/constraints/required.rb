module TableSchema
  class Constraints
    module Required

      def check_required
        if required? && is_empty?
          raise TableSchema::ConstraintError.new("The field `#{@field['name']}` requires a value")
        end
        true
      end

      private

      def required?
        required == true && @field['type'] != 'null'
      end

      def is_empty?
        null_values.include?(@value)
      end

      def required
        @constraints['required'].to_s == 'true'
      end

      def null_values
        ['null', 'none', 'nil', 'nan', '-', '']
      end

    end
  end
end
