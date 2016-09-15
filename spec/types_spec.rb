require 'spec_helper'

describe JsonTableSchema::Types do

  describe JsonTableSchema::Types::String do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'string',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::String.new(field) }

    it 'casts a simple string' do
      value = 'a string'
      expect(type.cast(value)).to eq('a string')
    end

    it 'returns an error if the value is not a string' do
      value = 1
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidCast)
    end

    context 'emails' do

      before(:each) do
        field['format'] = 'email'
      end

      it 'casts an email' do
        value = 'test@test.com'
        expect(type.cast(value)).to eq(value)

        value = '\$A12345@example.com'
        expect(type.cast(value)).to eq(value)

        value = '!def!xyz%abc@example.com'
        expect(type.cast(value)).to eq(value)
      end

      it 'fails with an invalid email' do
        value = 1
        expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidCast)

        value = 'notanemail'
        expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidEmail)
      end

    end

    context 'uris' do

      before(:each) do
        field['format'] = 'uri'
      end

      it 'casts a uri' do
        value = 'http://test.com'
        expect(type.cast(value)).to eq(value)
      end

      it 'raises an expection for an invalid URI' do
        value = 'notauri'
        expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidURI)
      end

    end

    context 'uuid' do

      before(:each) do
        field['format'] = 'uuid'
      end


      it 'casts a uuid' do
        value = '12345678123456781234567812345678'
        expect(type.cast(value)).to eq(value)

        value = 'urn:uuid:12345678-1234-5678-1234-567812345678'
        expect(type.cast(value)).to eq(value)

        value = '123e4567-e89b-12d3-a456-426655440000'
        expect(type.cast(value)).to eq(value)
      end

      it 'raises for invalid uuids' do
        value = '1234567812345678123456781234567?'
        expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidUUID)

        value = '1234567812345678123456781234567'
        expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidUUID)

        value = 'X23e4567-e89b-12d3-a456-426655440000'
        expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidUUID)
      end

    end

  end

  describe JsonTableSchema::Types::Number do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'number',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::Number.new(field) }

    it 'casts a simple number' do
      value = '10.00'
      expect(type.cast(value)).to eq(Float('10.00'))
    end

    it 'casts when the value is already cast' do
      [1, 1.0, Float(1)].each do |value|
        ['default', 'currency'].each do |format|
          field['format'] = format
          expect(type.cast(value)).to eq(Float(value))
        end
      end
    end

    it 'returns an error if the value is not a number' do
      value = 'string'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidCast)
    end

    it 'casts with localized settings' do
      [
        '10,000.00',
        '10,000,000.23',
        '10.23',
        '1,000',
        '100%',
        '1000‰'
      ].each do |value|
        expect { type.cast(value) }.to_not raise_error
      end

      field['groupChar'] = '#'

      [
        '10#000.00',
        '10#000#000.23',
        '10.23',
        '1#000'
      ].each do |value|
        expect { type.cast(value) }.to_not raise_error
      end

      field['decimalChar'] = '@'

      [
        '10#000@00',
        '10#000#000@23',
        '10@23',
        '1#000'
      ].each do |value|
        expect { type.cast(value) }.to_not raise_error
      end

    end

    context 'currencies' do

      let(:currency_field) {
        field['format'] = 'currency'
        field
      }

      let(:currency_type) {
        JsonTableSchema::Types::Number.new(currency_field)
      }

      it 'casts successfully' do
        [
          '10,000.00',
          '10,000,000.00',
          '$10000.00',
          '  10,000.00 €',
        ].each do |value|
          expect { currency_type.cast(value) }.to_not raise_error
        end

        field['decimalChar'] = ','
        field['groupChar'] = ' '

        [
          '10 000,00',
          '10 000 000,00',
          '10000,00 ₪',
          '  10 000,00 £',
        ].each do |value|
          expect { currency_type.cast(value) }.to_not raise_error
        end
      end

      it 'returns an error with a currency and a duff format' do
        value1 = '10,000a.00'
        value2 = '10+000.00'
        value3 = '$10:000.00'

        expect { currency_type.cast(value1) }.to raise_error(JsonTableSchema::InvalidCast)
        expect { currency_type.cast(value2) }.to raise_error(JsonTableSchema::InvalidCast)
        expect { currency_type.cast(value3) }.to raise_error(JsonTableSchema::InvalidCast)
      end

    end

  end

  describe JsonTableSchema::Types::Integer do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'integer',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::Integer.new(field) }

    it 'casts a simple integer' do
      value = '1'
      expect(type.cast(value)).to eq(1)
    end

    it 'raises when the value is not an integer' do
      value = 'string'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidCast)
    end

    it 'casts when value is already cast' do
      value = 1
      expect(type.cast(value)).to eq(1)
    end

  end

  describe JsonTableSchema::Types::Boolean do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'boolean',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::Boolean.new(field) }

    it 'casts a simple true value' do
      value = 't'
      expect(type.cast(value)).to be true
    end

    it 'casts a simple false value' do
      value = 'f'
      expect(type.cast(value)).to be false
    end

    it 'casts truthy values' do
      ['yes', 1, 't', 'true', true].each do |value|
        expect(type.cast(value)).to be true
      end
    end

    it 'casts falsy values' do
      ['no', 0, 'f', 'false', false].each do |value|
        expect(type.cast(value)).to be false
      end
    end

    it 'raises for invalid values' do
      value = 'not a true value'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidCast)

      value = 11231902333
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidCast)
    end

  end

  describe JsonTableSchema::Types::Null do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'null',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::Null.new(field) }

    it 'casts simple values' do
      value = 'null'
      expect(type.cast(value)).to be nil

      value = 'null'
      expect(type.cast(value)).to be nil

      value = 'none'
      expect(type.cast(value)).to be nil

      value = 'nil'
      expect(type.cast(value)).to be nil

      value = 'nan'
      expect(type.cast(value)).to be nil

      value = '-'
      expect(type.cast(value)).to be nil

      value = ''
      expect(type.cast(value)).to be nil
    end

    it 'raises for non null values' do
      value = 'nothing'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidCast)
    end

  end

  describe JsonTableSchema::Types::Object do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'object',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::Object.new(field) }

    it 'casts a hash' do
      value = {'key' => 'value'}
      expect(type.cast(value)).to eq(value)
    end

    it 'casts JSON string' do
      value = '{"key": "value"}'
      expect(type.cast(value)).to eq(JSON.parse(value))
    end

    it 'raises when value is not a hash' do
      value = ['boo', 'ya']
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidObjectType)
    end

    it 'raises when value is not JSON' do
      value = 'fdsfdsfsdfdsfdsfdsfds'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidObjectType)
    end

  end

  describe JsonTableSchema::Types::Array do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'array',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::Array.new(field) }

    it 'casts an array' do
      value = ['boo', 'ya']
      expect(type.cast(value)).to eq(value)
    end

    it 'casts JSON string' do
      value = '["boo", "ya"]'
      expect(type.cast(value)).to eq(JSON.parse(value))
    end

    it 'raises when value is not an array' do
      value = '{"key": "value"}'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidArrayType)
    end

    it 'raises when value is not JSON' do
      value = 'fdsfdsfsdfdsfdsfdsfds'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidArrayType)
    end

  end

  describe JsonTableSchema::Types::Date do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'date',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::Date.new(field) }

    it 'casts a standard ISO8601 date string' do
      value = '2019-01-01'
      expect(type.cast(value)).to eq(Date.new(2019,01,01))
    end

    it 'returns an error for a non ISO8601 date string by default' do
      value = '29/11/2015'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidDateType)
    end

    it 'casts any parseable date' do
      value = '10th Jan 1969'
      field['format'] = 'any'
      expect(type.cast(value)).to eq(Date.new(1969,01,10))
    end

    it 'raises an error for any when date is unparsable' do
      value = '10th Jan nineteen sixty nine'
      field['format'] = 'any'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidDateType)
    end

    it 'casts with a specified date format' do
      value = '10/06/2014'
      field['format'] = 'fmt:%d/%m/%Y'
      expect(type.cast(value)).to eq(Date.new(2014,06,10))
    end

    it 'assumes the first day of the month' do
      value = '2014-06'
      field['format'] = 'fmt:%Y-%m'
      expect(type.cast(value)).to eq(Date.new(2014,06,01))
    end

    it 'raises an error for an invalid fmt' do
      value = '2014/12/19'
      field['type'] = 'fmt:DD/MM/YYYY'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidDateType)
    end

    it 'raises an error for a valid fmt and invalid value' do
      value = '2014/12/19'
      field['type'] = 'fmt:%m/%d/%y'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidDateType)
    end

    it 'works with an already cast value' do
      value = Date.new(2014,06,01)
      ['default', 'any', 'fmt:%Y-%m-%d'].each do |f|
        field['format'] = f
        expect(type.cast(value)).to eq(value)
      end
    end

  end

  describe JsonTableSchema::Types::Time do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'time',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::Time.new(field) }

    it 'casts a standard ISO8601 time string' do
      value = '06:00:00'
      expect(type.cast(value)).to eq(Tod::TimeOfDay.new(6,0))
    end

    it 'raises an error when the string is not iso8601' do
      value = '3 am'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidTimeType)
    end

    it 'parses a generic time string' do
      value = '3:00 am'
      field['format'] = 'any'
      expect(type.cast(value)).to eq(Tod::TimeOfDay.new(3,0))
    end

    it 'raises an error when type format is incorrect' do
      value = 3.00
      self.field['format'] = 'fmt:any'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidTimeType)

      value = {}
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidTimeType)

      value = []
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidTimeType)
    end

    it 'works with an already cast value' do
      value = Tod::TimeOfDay.new(06,00)
      ['default', 'any', 'fmt:any'].each do |f|
        field['format'] = f
        expect(type.cast(value)).to eq(value)
      end
    end

  end

  describe JsonTableSchema::Types::DateTime do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'datetime',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::DateTime.new(field) }

    it 'casts a standard ISO8601 date string' do
      value = '2019-01-01T02:00:00Z'
      expect(type.cast(value)).to eq(DateTime.new(2019,01,01,2,0,0))
    end

    it 'guesses when fomat is any' do
      value = '10th Jan 1969 9am'
      field['format'] = 'any'
      expect(type.cast(value)).to eq(DateTime.new(1969,01,10,9,0,0))
    end

    it 'accepts a specified format' do
      value = '21/11/06 16:30'
      field['format'] = 'fmt:%d/%m/%y %H:%M'
      expect(type.cast(value)).to eq(DateTime.new(2006,11,21,16,30,00))
    end

    it 'fails with a non iso datetime by default' do
      value = 'Mon 1st Jan 2014 9 am'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidDateTimeType)
    end

    it 'raises an exception for an unparsable datetime' do
      value = 'the land before time'
      field['format'] = 'any'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidDateTimeType)
    end

    it 'raises if the date format is invalid' do
      value = '21/11/06 16:30'
      field['format'] = 'fmt:notavalidformat'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidDateTimeType)
    end

    it 'works fine with an already cast value' do
      value = DateTime.new(2015, 1, 1, 12, 0, 0)
      ['default', 'any', 'fmt:any'].each do |format|
        field['format'] = format
        expect(type.cast(value)).to eq(value)
      end
    end

  end

  describe JsonTableSchema::Types::GeoJSON do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'geojson',
        'format' => 'default',
        'constraints' => {
          'required' => false
        }
      }
    }

    let(:type) { JsonTableSchema::Types::GeoJSON.new(field) }

    it 'raises with invalid GeoJSON' do
      value = {'coordinates' => [0, 0, 0], 'type' =>'Point'}
        expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoJSONType)
    end

    it 'handles a GeoJSON hash' do
      value = {
        "properties" => {
          "Ã" => "Ã"
        },
        "type" => "Feature",
        "geometry" => nil,
      }

      expect(type.cast(value)).to eq(value)
    end

    it 'handles a GeoJSON string' do
      value = '{"geometry": null, "type": "Feature", "properties": {"\\u00c3": "\\u00c3"}}'

      expect(type.cast(value)).to eq(JSON.parse value)
    end

    it 'raises with an invalid JSON string' do
      value = 'notjson'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoJSONType)
    end

    it 'casts to none if string is blank' do
      value = ''
      # Required is false so cast null value to nil
      expect(type.cast(value)).to eq(nil)
    end

  end

  describe JsonTableSchema::Types::GeoPoint do

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'geopoint',
        'format' => 'default',
        'constraints' => {
          'required' => true
        }
      }
    }

    let(:type) { JsonTableSchema::Types::GeoPoint.new(field) }

    it 'handles a simple point string' do
      value = '10.0, 21.00'
      expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
    end

    it 'raises an error for points outside of the longitude range' do
      value = '310.0, 921.00'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
    end

    it 'raises an error for points outside of the latitude range' do
      value = '10.0, 921.00'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
    end

    it 'raises for something that is not a geopoint' do
      value = 'this is not a geopoint'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
    end

    it 'raises for non decimal values' do
      value = 'blah, blah'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
    end

    it 'raises for wrong length of points' do
      value = '10.0, 21.00, 1'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
    end

    it 'handles an array' do
      field['format'] = 'array'
      value = [10.0, 21.00]
      expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
      value = ["10.0", "21.00"]
      expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
    end

    it 'handles an array as a JSON string' do
      field['format'] = 'array'
      value = '[10.0, 21.00]'
      expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
    end

    it 'raises for an invalid array' do
      field['format'] = 'array'
      value = '1,2'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
      value = '["a", "b"]'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
      value = '1,2'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
    end

    it 'handles an object' do
      field['format'] = 'object'
      value = {"longitude" => 10.0, "latitude" => 21.00}
      expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
      value = {"longitude" => "10.0", "latitude" => "21.00"}
      expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
    end

    it 'handles an object as a JSON string' do
      field['format'] = 'object'
      value = '{"longitude": "10.0", "latitude": "21.00"}'
      expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
    end

    it 'raises for an invalid object' do
      field['format'] = 'object'
      value = '{"blah": "10.0", "latitude": "21.00"}'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
      value = '{"longitude": "a", "latitude": "21.00"}'
      expect { type.cast(value) }.to raise_error(JsonTableSchema::InvalidGeoPointType)
    end

  end

  context 'null values' do

    let(:none_string_types) {
      {
        'number' => JsonTableSchema::Types::Number,
        'integer' => JsonTableSchema::Types::Integer,
        'boolean' => JsonTableSchema::Types::Boolean,
        'array' => JsonTableSchema::Types::Array,
        'object' => JsonTableSchema::Types::Object,
        'date' => JsonTableSchema::Types::Date,
        'time' => JsonTableSchema::Types::Time,
        'datetime' => JsonTableSchema::Types::DateTime,
        'geopoint' => JsonTableSchema::Types::GeoPoint,
        'geojson' => JsonTableSchema::Types::GeoJSON,
        #'any' => JsonTableSchema::Types::Any
      }
    }

    let(:string_types) {
      {
        'string' => JsonTableSchema::Types::String,
      }
    }

    let(:field) {
      {
        'name' => 'Name',
        'type' => 'string',
        'format' => 'default',
        'constraints' => {
          'required' => true,
        }
      }
    }

    it 'raises for null values on required fields' do
      none_string_types.each do |name, value|
        field['type'] = name
        type = value.new(field)
        expect { type.cast('null') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('none') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('nil') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('nan') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('-') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('') }.to raise_error(JsonTableSchema::ConstraintError)
      end
    end

    it 'raises for null value on required string fields' do
      string_types.each do |name, value|
        field['type'] = name
        type = value.new(field)
        expect { type.cast('null') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('none') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('nil') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('nan') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('-') }.to raise_error(JsonTableSchema::ConstraintError)
        expect { type.cast('') }.to raise_error(JsonTableSchema::ConstraintError)
      end
    end

    it 'returns nil for optional fields' do
      field['constraints']['required'] = false
      none_string_types.each do |name, value|
        field['type'] = name
        type = value.new(field)
        expect(type.cast('null')).to eq(nil)
        expect(type.cast('none')).to eq(nil)
        expect(type.cast('nil')).to eq(nil)
        expect(type.cast('nan')).to eq(nil)
        expect(type.cast('-')).to eq(nil)
        expect(type.cast('')).to eq(nil)
      end
    end

    it 'returns nil for optional string types' do
      field['constraints']['required'] = false
      string_types.each do |name, value|
        field['type'] = name
        type = value.new(field)
        expect(type.cast('null')).to eq(nil)
        expect(type.cast('none')).to eq(nil)
        expect(type.cast('nil')).to eq(nil)
        expect(type.cast('nan')).to eq(nil)
        expect(type.cast('-')).to eq(nil)
        expect(type.cast('')).to eq(nil)
      end
    end

  end


end

#
# class TestAny(base.BaseTestCase):
#     def setUp(self):
#         super(TestAny, self).setUp()
#         self.field = {
#             'name': 'Name',
#             'type': 'any',
#             'format': 'default',
#             'constraints': {
#                 'required': True
#             }
#         }
#
#     def test_any_type(self):
#         for value in ['1', 2, time(12, 0, 0)]:
#             _type = types.AnyType(self.field)
#             self.assertEquals(_type.cast(value), value)
