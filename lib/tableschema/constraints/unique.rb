module TableSchema
  class Constraints
    module Unique

      def check_unique
        # This check is done in Table because it needs the previous values in the column
        true
      end

    end
  end
end
