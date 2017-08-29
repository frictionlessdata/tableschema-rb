module TableSchema
  module Types
    class Number < Base

      def name
        'number'
      end

      def self.supported_constraints
        [
          'required',
          'unique',
          'pattern',
          'enum',
          'minimum',
          'maximum',
        ]
      end

      def type
        ::Float
      end


      def cast_default(value)
        case value
        when type
          value
        when ::Integer
          Float(value)
        when ::String
          process_string(value)
        end
      rescue ArgumentError
        raise TableSchema::InvalidCast.new("#{value} is not a #{name}")
      end

      private

        def process_string(value)
          case value
          when 'NaN'
            Float::NAN
          when '-INF'
            -Float::INFINITY
          when 'INF'
            Float::INFINITY
          else
            group_char = @field.fetch(:groupChar, TableSchema::DEFAULTS[:group_char])
            decimal_char = @field.fetch(:decimalChar, TableSchema::DEFAULTS[:decimal_char])
            bare_number = @field.fetch(:bareNumber, TableSchema::DEFAULTS[:bare_number])
            formatted_value = value
            formatted_value = formatted_value.gsub(group_char, '')
            formatted_value = formatted_value.gsub(decimal_char, '.')
            if !bare_number
              formatted_value = formatted_value.gsub(/((^\D*)|(\D*$))/, '')
            end
            Float(formatted_value)
          end
        end
    end
  end
end
