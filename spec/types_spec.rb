require 'spec_helper'

describe TableSchema::Types do

  context 'missing values' do

    let(:non_string_types) {
      [
        'number',
        'integer',
        'boolean',
        'array',
        'object',
        'date',
        'time',
        'datetime',
        'geopoint',
        'geojson',
        'any',
        'year',
        'yearmonth',
        'duration',
      ]
    }

    let(:string_types) {
      [
        'string',
      ]
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
      non_string_types.each do |name|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs, missing_values)
        expect { field.cast_value('null') }.to raise_error(TableSchema::ConstraintError)
        expect { field.cast_value('NaN') }.to raise_error(TableSchema::ConstraintError)
      end
    end

    it 'raises for null value on required string fields' do
      string_types.each do |name|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs, missing_values)
        expect { field.cast_value('null') }.to raise_error(TableSchema::ConstraintError)
        expect { field.cast_value('NaN') }.to raise_error(TableSchema::ConstraintError)
      end
    end

    it 'returns nil for optional fields' do
      field_attrs[:constraints][:required] = false
      non_string_types.each do |name|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs, missing_values)
        expect(field.cast_value('null')).to eq(nil)
        expect(field.cast_value('NaN')).to eq(nil)
      end
    end

    it 'returns nil for optional string types' do
      field_attrs[:constraints][:required] = false
      string_types.each do |name|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs, missing_values)
        expect(field.cast_value('null')).to eq(nil)
        expect(field.cast_value('NaN')).to eq(nil)
      end
    end

    it 'converts empty string to nil by default' do
      field_attrs[:constraints][:required] = false
      non_string_types.each do |name|
        field_attrs[:type] = name
        field = TableSchema::Field.new(field_attrs)
        expect(field.cast_value('')).to eq(nil)
      end
    end

    it 'doesn\'t convert empty string to nil for string types by default' do
      field_attrs[:constraints][:required] = false
      string_types.each do |name|
        field_attrs[:type] = name.to_s
        field = TableSchema::Field.new(field_attrs)
        expect(field.cast_value('')).to eq('')
      end
    end

  end

end
