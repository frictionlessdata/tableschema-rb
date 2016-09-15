module JsonTableSchema
  class Constraints
    module Maximum

      def check_maximum
        if @value > parse_constraint(@constraints['maximum'])
          raise JsonTableSchema::ConstraintError.new("The field `#{@field['name']}` must not be more than #{@constraints['maximum']}")
        end
        true
      end

    end
  end
end
