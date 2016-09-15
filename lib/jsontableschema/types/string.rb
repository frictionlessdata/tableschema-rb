module JsonTableSchema
  module Types
    class String < Base

      def name
        'string'
      end

      def self.supported_constraints
        [
          'required',
          'pattern',
          'enum',
          'minLength',
          'maxLength',
        ]
      end

      def type
        ::String
      end

      def email_pattern
        /[^@]+@[^@]+\.[^@]+/
      end

      def cast_default(value)
        if value.is_a?(type)
          return value
        else
          raise JsonTableSchema::InvalidCast.new("#{value} is not a #{name}")
        end
      end

      def cast_email(value)
        value = cast_default(value)
        if value =~ email_pattern
          value
        else
          raise JsonTableSchema::InvalidEmail.new("#{value} is not a valid email")
        end
      end

      def cast_uri(value)
        value = cast_default(value)
        if value =~ URI::regexp
          value
        else
          raise JsonTableSchema::InvalidURI.new("#{value} is not a valid uri")
        end
      end

      def cast_uuid(value)
        value = cast_default(value)
        if UUID.validate(value)
          value
        else
          raise JsonTableSchema::InvalidUUID.new("#{value} is not a valid UUID")
        end
      end

    end
  end
end
