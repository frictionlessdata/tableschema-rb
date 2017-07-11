module TableSchema
  module Types
    class GeoJSON < Base

      def name
        'geojson'
      end

      def self.supported_constraints
        [
          'required',
          'unique',
          'pattern',
          'enum'
        ]
      end

      def type
        ::Hash
      end

      def cast_default(value)
        parsed_value = parse_value(value)
        JSON::Validator.validate!(geojson_schema, parsed_value)
        parsed_value
      rescue JSON::Schema::ValidationError, JSON::ParserError
        raise TableSchema::InvalidGeoJSONType.new("#{value} is not valid GeoJSON")
      end

      def cast_topojson(value)
        parsed_value = parse_value(value)
        JSON::Validator.validate!(topojson_schema, parsed_value)
        parsed_value
      rescue JSON::Schema::ValidationError, JSON::ParserError
        raise TableSchema::InvalidTopoJSONType.new("#{value} is not valid TopoJSON")
      end

      private

      def parse_value(value)
        if value.is_a?(type)
          value
        else
          JSON.parse(value, symbolize_names: true)
        end
      end

      def geojson_schema
        path = File.join( File.dirname(__FILE__), "..", "..", "profiles", "geojson.json" )
        JSON.parse(File.read(path), symbolize_names: true)
      end

      def topojson_schema
        path = File.join( File.dirname(__FILE__), "..", "..", "profiles", "topojson.json" )
        JSON.parse(File.read(path), symbolize_names: true)
      end

    end
  end
end
