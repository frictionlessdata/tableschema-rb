module TableSchema
  class Constraints
    module Unique

      def check_unique
        if @previous_values.include?(@value)
          raise TableSchema::ConstraintError.new("The value for the field `#{@field[:name]}` should be unique")
        end
        true
      end

      private

      def parsed_unique
        @constraints[:unique].to_s == 'true'
      end
    end
  end
end
