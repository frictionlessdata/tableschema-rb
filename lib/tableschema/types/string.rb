module TableSchema
  module Types
    class String < Base

      def name
        'string'
      end

      def self.supported_constraints
        [
          'required',
          'unique',
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
          raise TableSchema::InvalidCast.new("#{value} is not a #{name}")
        end
      end

      def cast_email(value)
        value = cast_default(value)
        if (value =~ email_pattern) != nil
          value
        else
          raise TableSchema::InvalidEmail.new("#{value} is not a valid email")
        end
      end

      def cast_uri(value)
        value = cast_default(value)
        if (value =~ URI::regexp) != nil
          value
        else
          raise TableSchema::InvalidURI.new("#{value} is not a valid uri")
        end
      end

      def cast_uuid(value)
        value = cast_default(value)
        if UUID.validate(value)
          value
        else
          raise TableSchema::InvalidUUID.new("#{value} is not a valid UUID")
        end
      end

      def cast_binary(value)
        value = cast_default(value)
        Base64.strict_decode64(value)
      rescue ArgumentError
        raise TableSchema::InvalidBinary.new("#{value} is not a valid binary string")
      end

    end
  end
end
