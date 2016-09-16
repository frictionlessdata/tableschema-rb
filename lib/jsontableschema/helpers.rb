module JsonTableSchema
  module Helpers

    def cast_boolean(value)
      if value.is_a?(Boolean)
        return value
      elsif true_values.include?(value.to_s.downcase)
        true
      elsif false_values.include?(value.to_s.downcase)
        false
      else
        nil
      end
    end

    def true_values
      ['yes', 'y', 'true', 't', '1']
    end

    def false_values
      ['no', 'n', 'false', 'f', '0']
    end

    def get_class_for_type(type)
      "JsonTableSchema::Types::#{type.capitalize}"
    end

  end
end
