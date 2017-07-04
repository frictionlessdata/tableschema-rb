module TableSchema
  module Types
    class Number < Base

      def name
        'number'
      end

      def self.supported_constraints
        [
          'required',
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
            formatted_value = value.gsub(group_char, '').gsub(decimal_char, '.')
            if formatted_value.match(percent_chars)
              process_percent(formatted_value)
            elsif @field.fetch(:currency, nil)
              process_currency(formatted_value)
            else
              Float(formatted_value)
            end
          end
        end

        def process_percent(value)
          Float(value.gsub(percent_chars, '')) / 100
        end

        def process_currency(value)
          Float(value.gsub(@field[:currency], ''))
        end

        def percent_chars
          /%|‰|‱|％|﹪|٪/
        end
    end
  end
end
