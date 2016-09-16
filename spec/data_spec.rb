require 'spec_helper'

describe JsonTableSchema::Data do
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

  let(:schema) { JsonTableSchema::Schema.new(schema_hash) }

  it 'converts a row' do
    row = ['string', '10.0', '1', 'string', 'string']
    expect(schema.convert_row(row)).to eq(['string', Float(10.0), 1, 'string', 'string'])
  end

  it 'converts a row with null values' do
    row = ['string', '', '-', 'string', 'null']
    expect(schema.convert_row(row)).to eq(['string', nil, nil, 'string', nil])
  end

  it 'raises an error for a row with too few items' do
    row = ['string', '10.0', '1', 'string']
    expect { schema.convert_row(row) }.to raise_error(
      JsonTableSchema::ConversionError,
      'The number of items to convert (4) does not match the number of headers in the schema (5)'
    )
  end

  it 'raises an error for a row with too many items' do
    row = ['string', '10.0', '1', 'string', 1, 2]
    expect { schema.convert_row(row) }.to raise_error(
      JsonTableSchema::ConversionError,
      'The number of items to convert (6) does not match the number of headers in the schema (5)'
    )
  end

  it 'raises an error if a column has the wrong type' do
    row = ['string', 'notdecimal', '10.6', 'string', 'string']
    expect { schema.convert_row(row) }.to raise_error(
      JsonTableSchema::InvalidCast,
      'notdecimal is not a number'
    )
  end

  it 'raises multiple errors if fail_fast is set to false' do
    row = ['string', 'notdecimal', '10.6', 'string', 'string']
    expect { schema.convert_row(row, false) }.to raise_error(
      JsonTableSchema::MultipleInvalid,
      'There were errors parsing the row'
    )
    expect(schema.errors.count).to eq(2)
  end

end


#
# def test_convert_rows(self):
#     m = model.SchemaModel(self.schema)
#     rows = m.convert([['string', '10.0', '1', 'string', 'string'],
#                       ['string', '10.0', '1', 'string', 'string'],
#                       ['string', '10.0', '1', 'string', 'string'],
#                       ['string', '10.0', '1', 'string', 'string'],
#                       ['string', '10.0', '1', 'string', 'string']])
#     for row in rows:
#         self.assertEqual(['string', Decimal(10.0), 1, 'string', 'string'],
#                          row)
#
# def test_convert_rows_invalid_in_various_rows_fail_fast(self):
#     m = model.SchemaModel(self.schema)
#     self.assertRaises(
#         exceptions.InvalidCastError,
#         list,
#         m.convert(
#             [['string', 'not', '1', 'string', 'string'],
#              ['string', '10.0', '1', 'string', 'string'],
#              ['string', 'an', '1', 'string', 'string'],
#              ['string', '10.0', '1', 'string', 'string'],
#              ['string', '10.0', 'integer', 'string', 'string']],
#             fail_fast=True)
#     )
#
# def test_convert_rows_invalid_in_various_rows(self):
#     m = model.SchemaModel(self.schema)
#     with self.assertRaises(exceptions.MultipleInvalid) as cm:
#         list(m.convert([['string', 'not', '1', 'string', 'string'],
#                         ['string', '10.0', '1', 'string', 'string'],
#                         ['string', 'an', '1', 'string', 'string'],
#                         ['string', '10.0', '1', 'string', 'string'],
#                         ['string', '10.0', 'integer', 'string', 'string']])
#              )
#         self.assertEquals(3, len(cm.errors))
#
# def test_convert_rows_invalid_varying_length_rows(self):
#     m = model.SchemaModel(self.schema)
#     with self.assertRaises(exceptions.MultipleInvalid) as cm:
#         list(m.convert([['string', '10.0', '1', 'string'],
#                         ['string', '10.0', '1', 'string', 'string'],
#                         ['string', '10.0', '1', 'string', 'string', 1],
#                         ['string', '10.0', '1', 'string', 'string'],
#                         ['string', '10.0', '1', 'string', 'string']])
#              )
#         self.assertEquals(2, len(cm.errors))
#
# def test_convert_rows_invalid_varying_length_rows_fail_fast(self):
#     m = model.SchemaModel(self.schema)
#     self.assertRaises(
#         exceptions.ConversionError,
#         list,
#         m.convert([['string', '10.0', '1', 'string'],
#                    ['string', '10.0', '1', 'string', 'string'],
#                    ['string', '10.0', '1', 'string', 'string', 1],
#                    ['string', '10.0', '1', 'string', 'string'],
#                    ['string', '10.0', '1', 'string', 'string']],
#                   fail_fast=True)
#     )






# def test_invalid_jts_raises(self):
#     source = os.path.join(self.data_dir, 'schema_invalid_empty.json')
#
#     self.assertRaises(exceptions.InvalidSchemaError,
#                       model.SchemaModel, source)
