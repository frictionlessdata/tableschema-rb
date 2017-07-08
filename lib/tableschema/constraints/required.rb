module TableSchema
  class Constraints
    module Required

      def check_required
        if parsed_required == true && value_is_empty?
          raise TableSchema::ConstraintError.new("The field `#{@field[:name]}` requires a value")
        end
        true
      end

      private

      def value_is_empty?
        @value.nil? || @value == ''
      end

      def parsed_required
        @constraints[:required].to_s == 'true'
      end
    end
  end
end
