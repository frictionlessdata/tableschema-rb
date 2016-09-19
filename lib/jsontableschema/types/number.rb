module JsonTableSchema
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

      def currency_symbols
        ISO4217::Currency.currencies.to_a.map { |c| Regexp.escape(c.last.symbol) rescue nil }.delete_if { |s| s.nil? }
      end

      def cast_default(value)
        return value if value.class == type
        return Float(value) if value.class == ::Fixnum

        value = preprocess_value(value)
        return Float(value)
      rescue ArgumentError
        raise JsonTableSchema::InvalidCast.new("#{value} is not a #{name}")
      end

      def cast_currency(value)
        cast_default(value)
      rescue JsonTableSchema::InvalidCast
        value = preprocess_value(value)
        re = Regexp.new currency_symbols.join('|')
        value.gsub!(re, '')
        cast_default(value)
      end

      private

        def preprocess_value(value)
          group_char = @field.fetch('groupChar', ',')
          decimal_char = @field.fetch('decimalChar', '.')
          percent_char = /%|‰|‱|％|﹪|٪/
          value.gsub(group_char, '')
               .gsub(decimal_char, '.')
               .gsub(percent_char, '')
               .gsub(Regexp.new(currency_symbols.join '|'), '')
        end

    end
  end
end
