module TableSchema
  module Helpers

    def convert_to_boolean(value)
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
      "TableSchema::Types::#{type_class_lookup[type] || 'String'}"
    end

    def type_class_lookup
      {
        'any' => 'Any',
        'array' => 'Array',
        'base' => 'Base',
        'boolean' => 'Boolean',
        'date' => 'Date',
        'datetime' => 'DateTime',
        'geojson' => 'GeoJSON',
        'geopoint' => 'GeoPoint',
        'integer' => 'Integer',
        'number' => 'Number',
        'object' => 'Object',
        'string' => 'String',
        'time' => 'Time',
      }
    end

  end
end
