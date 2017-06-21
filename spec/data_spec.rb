require 'spec_helper'

describe TableSchema::Data do
  let(:schema_hash) {
    {
      "fields" => [
          {
              "name" => "id",
              "type" => "string",
              "constraints" => {
                  "required" => true,
              }
          },
          {
              "name" => "height",
              "type" => "number",
              "constraints" => {
                  "required" => false,
              }
          },
          {
              "name" => "age",
              "type" => "integer",
              "constraints" => {
                  "required" => false,
              }
          },
          {
              "name" => "name",
              "type" => "string",
              "constraints" => {
                  "required" => true,
              }
          },
          {
              "name" => "occupation",
              "type" => "string",
              "constraints" => {
                  "required" => false,
              }
          },

      ]
    }
  }

  let(:schema) { TableSchema::Schema.new(schema_hash) }

  context 'cast_row' do

    it 'converts a row' do
      row = ['string', '10.0', '1', 'string', 'string']
      expect(schema.cast_row(row)).to eq(['string', Float(10.0), 1, 'string', 'string'])
    end

    it 'converts a row with null values' do
      row = ['string', '', '-', 'string', 'null']
      expect(schema.cast_row(row)).to eq(['string', nil, nil, 'string', nil])
    end

    it 'raises an error for a row with too few items' do
      row = ['string', '10.0', '1', 'string']
      expect { schema.cast_row(row) }.to raise_error(
        TableSchema::ConversionError,
        'The number of items to convert (4) does not match the number of headers in the schema (5)'
      )
    end

    it 'raises an error for a row with too many items' do
      row = ['string', '10.0', '1', 'string', 1, 2]
      expect { schema.cast_row(row) }.to raise_error(
        TableSchema::ConversionError,
        'The number of items to convert (6) does not match the number of headers in the schema (5)'
      )
    end

    it 'raises an error if a column has the wrong type' do
      row = ['string', 'notdecimal', '10.6', 'string', 'string']
      expect { schema.cast_row(row) }.to raise_error(
        TableSchema::InvalidCast,
        'notdecimal is not a number'
      )
    end

    it 'raises multiple errors if fail_fast is set to false' do
      row = ['string', 'notdecimal', '10.6', 'string', 'string']
      expect { schema.cast_row(row, false) }.to raise_error(
        TableSchema::MultipleInvalid,
        'There were errors parsing the data'
      )
      expect(schema.errors.count).to eq(2)
    end

    it 'aliases to convert_row' do
      row = ['string', '10.0', '1', 'string', 'string']
      expect(schema.convert_row(row)).to eq(['string', Float(10.0), 1, 'string', 'string'])
    end

  end

  context 'cast_rows' do

    it 'converts valid data' do
      rows = [
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string']
      ]

      converted_rows = schema.cast_rows(rows)

      converted_rows.each do |row|
        expect(row).to eq(['string', Float(10.0), 1, 'string', 'string'])
      end
    end

    it 'raises the first error it comes to' do
      rows = [
        ['string', 'not', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', 'an', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', 'integer', 'string', 'string']
      ]

      expect { schema.cast_rows(rows) }.to raise_error(
        TableSchema::InvalidCast,
        'not is not a number'
      )
    end

    it 'collects errors when fail_fast is set to false' do
      rows = [
        ['string', 'not', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', 'an', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', 'integer', 'string', 'string']
      ]

      expect { schema.cast_rows(rows, false) }.to raise_error(
        TableSchema::MultipleInvalid,
        'There were errors parsing the data'
      )
      expect(schema.errors.count).to eq(3)
    end

    it 'collects row length errors too' do
      rows = [
        ['string', '10.0', '1', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string', 1],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string']
      ]

      expect { schema.cast_rows(rows, false) }.to raise_error(
        TableSchema::MultipleInvalid,
        'There were errors parsing the data'
      )
      expect(schema.errors.count).to eq(2)
    end

    it 'fails on the first row length error when fail_fast is true' do
      rows = [
        ['string', '10.0', '1', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string', 1],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string']
      ]

      expect { schema.cast_rows(rows) }.to raise_error(
        TableSchema::ConversionError,
        'The number of items to convert (4) does not match the number of headers in the schema (5)'
      )
    end

    it 'aliases to convert' do
      rows = [
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string'],
        ['string', '10.0', '1', 'string', 'string']
      ]

      converted_rows = schema.convert(rows)

      converted_rows.each do |row|
        expect(row).to eq(['string', Float(10.0), 1, 'string', 'string'])
      end
    end

  end

end
