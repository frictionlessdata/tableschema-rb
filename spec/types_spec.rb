require 'spec_helper'

describe TableSchema::Types do

  context 'missing values' do

    let(:non_string_types) {
      {
        number: TableSchema::Types::Number,
        integer: TableSchema::Types::Integer,
        boolean: TableSchema::Types::Boolean,
        array: TableSchema::Types::Array,
        object: TableSchema::Types::Object,
        date: TableSchema::Types::Date,
        time: TableSchema::Types::Time,
        datetime: TableSchema::Types::DateTime,
        geopoint: TableSchema::Types::GeoPoint,
        geojson: TableSchema::Types::GeoJSON,
        any: TableSchema::Types::Any,
        year: TableSchema::Types::Year,
        yearmonth: TableSchema::Types::YearMonth,
        duration: TableSchema::Types::Duration,
      }
    }

    let(:string_types) {
      {
        string: TableSchema::Types::String,
      }
    }

    let(:field_attrs) {
      {
        name: 'Name',
        type: 'string',
        format: 'default',
        constraints: {
          required: true,
        }
      }
    }

    let(:missing_values) {
      [
        'null',
        'NaN'
      ]
    }

    it 'raises for missing_values on required fields' do
      non_string_types.each do |name, type_class|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs, missing_values)
        type = type_class.new(field)
        expect { type.cast('null') }.to raise_error(TableSchema::ConstraintError)
        expect { type.cast('NaN') }.to raise_error(TableSchema::ConstraintError)
      end
    end

    it 'raises for null value on required string fields' do
      string_types.each do |name, type_class|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs, missing_values)
        type = type_class.new(field)
        expect { type.cast('null') }.to raise_error(TableSchema::ConstraintError)
        expect { type.cast('NaN') }.to raise_error(TableSchema::ConstraintError)
      end
    end

    it 'returns nil for optional fields' do
      field_attrs[:constraints][:required] = false
      non_string_types.each do |name, type_class|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs, missing_values)
        type = type_class.new(field)
        expect(type.cast('null')).to eq(nil)
        expect(type.cast('NaN')).to eq(nil)
      end
    end

    it 'returns nil for optional string types' do
      field_attrs[:constraints][:required] = false
      string_types.each do |name, type_class|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs, missing_values)
        type = type_class.new(field)
        expect(type.cast('null')).to eq(nil)
        expect(type.cast('NaN')).to eq(nil)
      end
    end

    it 'converts empty string to nil by default' do
      field_attrs[:constraints][:required] = false
      non_string_types.each do |name, type_class|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs)
        type = type_class.new(field)
        expect(type.cast('')).to eq(nil)
      end
    end

    it 'doesn\'t convert empty string to nil for string types by default' do
      field_attrs[:constraints][:required] = false
      string_types.each do |name, type_class|
        field_attrs[:type] = name.to_s
        field = TableSchema::Field.new(field_attrs)
        type = type_class.new(field)
        expect(type.cast('')).to eq('')
      end
    end

  end

end
