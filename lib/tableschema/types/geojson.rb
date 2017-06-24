module TableSchema
  module Types
    class GeoJSON < Base

      def name
        'geojson'
      end

      def self.supported_constraints
        [
          'required',
          'pattern',
          'enum'
        ]
      end

      def type
        ::Hash
      end

      def cast_default(value)
        value = JSON.parse(value) if !value.is_a?(type)
        JSON::Validator.validate!(geojson_schema, value)
        value
      rescue JSON::Schema::ValidationError, JSON::ParserError
        raise TableSchema::InvalidGeoJSONType.new("#{value} is not valid GeoJSON")
      end

      private

      def geojson_schema
        path = File.join( File.dirname(__FILE__), "..", "..", "profiles", "geojson.json" )
        @geojson_schema ||= JSON.parse File.read(path)
      end

    end
  end
end
