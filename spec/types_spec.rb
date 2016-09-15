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
        'type' => 'boolean',
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

  describe JsonTableSchema::Types::DateTime do

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

  end


end

# class TestGeoJson(base.BaseTestCase):



#
#     def test_geojson_type_simple_false(self):
#         value = ''
#         self.field['type'] = 'geojson'
#         _type = types.GeoJSONType(self.field)
#
#         # Required is false so cast null value to None
#         assert _type.cast(value) == None
#
#
# class TestGeoPoint(base.BaseTestCase):
#     def setUp(self):
#         super(TestGeoPoint, self).setUp()
#         self.field = {
#             'name': 'Name',
#             'type': 'geopoint',
#             'format': 'default',
#             'constraints': {
#                 'required': True
#             }
#         }
#
#     def test_geopoint_type_simple_true(self):
#         value = '10.0, 21.00'
#         _type = types.GeoPointType(self.field)
#         self.assertEquals(_type.cast(value), [Decimal(10.0), Decimal(21)])
#
#     def test_values_outside_longitude_range(self):
#         value = '310.0, 921.00'
#         _type = types.GeoPointType(self.field)
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast, value)
#
#     def test_values_outside_latitude_range(self):
#         value = '10.0, 921.00'
#         _type = types.GeoPointType(self.field)
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast, value)
#
#     def test_geopoint_type_simple_false(self):
#         value = 'this is not a geopoint'
#         _type = types.GeoPointType(self.field)
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast, value)
#
#     def test_non_decimal_values(self):
#         value = 'blah, blah'
#         _type = types.GeoPointType(self.field)
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast, value)
#
#     def test_wrong_length_of_points(self):
#         value = '10.0, 21.00, 1'
#         _type = types.GeoPointType(self.field)
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast, value)
#
#     def test_array(self):
#         self.field['format'] = 'array'
#         _type = types.GeoPointType(self.field)
#         self.assertEquals(_type.cast('[10.0, 21.00]'),
#                           [Decimal(10.0), Decimal(21)])
#         self.assertEquals(_type.cast('["10.0", "21.00"]'),
#                           [Decimal(10.0), Decimal(21)])
#
#     def test_array_invalid(self):
#         self.field['format'] = 'array'
#         _type = types.GeoPointType(self.field)
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast, '1,2')
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast,
#                           '["a", "b"]')
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast,
#                           '[1, 2, 3]')
#
#     def test_object(self):
#         self.field['format'] = 'object'
#         _type = types.GeoPointType(self.field)
#         self.assertEquals(_type.cast('{"longitude": 10.0, "latitude": 21.00}'),
#                           [Decimal(10.0), Decimal(21)])
#         self.assertEquals(
#             _type.cast('{"longitude": "10.0", "latitude": "21.00"}'),
#             [Decimal(10.0), Decimal(21)]
#         )
#
#     def test_array_object(self):
#         self.field['format'] = 'object'
#         _type = types.GeoPointType(self.field)
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast, '[ ')
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast,
#                           '{"blah": "10.0", "latitude": "21.00"}')
#         self.assertRaises(exceptions.InvalidGeoPointType, _type.cast,
#                           '{"longitude": "a", "latitude": "21.00"}')
#
#
#
# class TestNullValues(base.BaseTestCase):
#
#     none_string_types = {
#         'number': types.NumberType,
#         'integer': types.IntegerType,
#         'boolean': types.BooleanType,
#         'null': types.NullType,
#         'array': types.ArrayType,
#         'object': types.ObjectType,
#         'date': types.DateType,
#         'time': types.TimeType,
#         'datetime': types.DateTimeType,
#         'geopoint': types.GeoPointType,
#         'geojson': types.GeoJSONType,
#         'any': types.AnyType,
#     }
#
#     string_types = {
#         'string': types.StringType,
#     }
#
#     def setUp(self):
#         super(TestNullValues, self).setUp()
#         self.field = {
#             'name': 'Name',
#             'type': 'string',
#             'format': 'default',
#             'constraints': {
#                 'required': True,
#             }
#         }
#
#     def test_required_field_non_string_types(self):
#         error = exceptions.ConstraintError
#         for name, value in self.none_string_types.items():
#             self.field['type'] = name
#             _type = value(self.field)
#             self.assertRaises(error, _type.cast, 'null')
#             self.assertRaises(error, _type.cast, 'none')
#             self.assertRaises(error, _type.cast, 'nil')
#             self.assertRaises(error, _type.cast, 'nan')
#             self.assertRaises(error, _type.cast, '-')
#             self.assertRaises(error, _type.cast, '')
#
#     def test_required_field_string_types(self):
#         error = exceptions.ConstraintError
#         for name, value in self.string_types.items():
#             self.field['type'] = name
#             _type = value(self.field)
#             self.assertRaises(error, _type.cast, 'null')
#             self.assertRaises(error, _type.cast, 'none')
#             self.assertRaises(error, _type.cast, 'nil')
#             self.assertRaises(error, _type.cast, 'nan')
#             self.assertRaises(error, _type.cast, '-')
#             assert _type.cast('') == ''
#
#     def test_optional_field_non_string_types(self):
#         self.field['constraints']['required'] = False
#         for name, value in self.none_string_types.items():
#             self.field['type'] = name
#             _type = value(self.field)
#             assert _type.cast('null') == None
#             assert _type.cast('none') == None
#             assert _type.cast('nil') == None
#             assert _type.cast('nan') == None
#             assert _type.cast('-') == None
#             assert _type.cast('') == None
#
#     def test_optional_field_non_string_types(self):
#         self.field['constraints']['required'] = False
#         for name, value in self.string_types.items():
#             self.field['type'] = name
#             _type = value(self.field)
#             assert _type.cast('null') == None
#             assert _type.cast('none') == None
#             assert _type.cast('nil') == None
#             assert _type.cast('nan') == None
#             assert _type.cast('-') == None
#             assert _type.cast('') == ''
#
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
