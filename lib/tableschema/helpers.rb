module TableSchema
  module Helpers

    def deep_symbolize_keys(descriptor)
      case descriptor
      when Hash
        descriptor.inject({}) do |new_descriptor, (key, val)|
          key_sym = key.respond_to?(:to_sym) ? key.to_sym : key
          new_descriptor[key_sym] = deep_symbolize_keys(val)
          new_descriptor
        end
      when Enumerable
        descriptor.map{ |el| deep_symbolize_keys(el)}
      else
        descriptor
      end
    end

    def get_class_for_type(type)
      "TableSchema::Types::#{type_class_lookup[type.to_sym] || 'String'}"
    end

    def type_class_lookup
      {
        any: 'Any',
        array: 'Array',
        base: 'Base',
        boolean: 'Boolean',
        date: 'Date',
        datetime: 'DateTime',
        geojson: 'GeoJSON',
        geopoint: 'GeoPoint',
        integer: 'Integer',
        number: 'Number',
        object: 'Object',
        string: 'String',
        time: 'Time',
        year: 'Year',
        yearmonth: 'YearMonth',
        duration: 'Duration',
      }
    end

    def read_file(descriptor)
      if (descriptor =~ /http/) != 0
	File.open(descriptor).read
      else
        URI.parse(descriptor).open.read
      end
    end

  end
end
