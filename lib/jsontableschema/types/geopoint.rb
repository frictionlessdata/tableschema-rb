module JsonTableSchema
  module Types
    class GeoPoint < Base

      def name
        'geopoint'
      end

      def self.supported_constraints
        [
          'required',
          'pattern',
          'enum'
        ]
      end

      def types
        [::String, ::Array, ::Hash]
      end

      def cast_default(value)
        latlng = value.split(',', 2)
        cast_array([latlng[0], latlng[1]])
      end

      def cast_object(value)
        value = JSON.parse(value) if value.is_a?(::String)
        cast_array([value['longitude'], value['latitude']])
      rescue JSON::ParserError
        raise JsonTableSchema::InvalidGeoPointType.new("#{value} is not a valid geopoint")
      end

      def cast_array(value)
        value = JSON.parse(value) if value.is_a?(::String)
        value = [Float(value[0]), Float(value[1])]
        check_latlng_range(value)
        value
      rescue JSON::ParserError, ArgumentError, TypeError
        raise JsonTableSchema::InvalidGeoPointType.new("#{value} is not a valid geopoint")
      end

      private

      def check_latlng_range(geopoint)
        longitude = geopoint[0]
        latitude = geopoint[1]
        if longitude >= 180 or longitude <= -180
          raise JsonTableSchema::InvalidGeoPointType.new("longtitude should be between -180 and 180, found `#{longitude}`")
        elsif latitude >= 90 or latitude <= -90
          raise JsonTableSchema::InvalidGeoPointType.new("longtitude should be between -90 and 90, found `#{latitude}`")
        end
      end

    end
  end
end
