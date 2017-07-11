module TableSchema
  module Types
    class Duration < Base

      def name
        'duration'
      end

      def self.supported_constraints
        [
          'required',
          'unique',
          'enum',
          'minimum',
          'maximum',
        ]
      end

      def type
        ActiveSupport::Duration
      end

      def cast_default(value)
        ActiveSupport::Duration.parse(value)
      rescue ActiveSupport::Duration::ISO8601Parser::ParsingError, TypeError
          raise TableSchema::InvalidDurationType.new("#{value} is not a valid duration")
      end

    end
  end
end
