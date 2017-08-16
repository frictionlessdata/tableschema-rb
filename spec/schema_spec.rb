require 'spec_helper'

describe TableSchema::Schema do

  context 'initializes' do

    it 'with a hash' do
      hash = load_descriptor('schema_valid_full.json')
      schema = TableSchema::Schema.new(hash)
      expect(schema[:fields].count).to eq(22)
      expect(schema[:fields].first.class).to eq(TableSchema::Field)
    end

    it 'with a file' do
      file = File.join( File.dirname(__FILE__), "fixtures", "schema_valid_full.json")
      schema = TableSchema::Schema.new(file)
      expect(schema[:fields].count).to eq(22)
    end

    it 'with a url' do
      path = File.join( File.dirname(__FILE__), "fixtures", "schema_valid_full.json")
      url = 'http://www.example.com/schema.json'
      stub_request(:get, url)
                  .to_return(body: File.open(path))

      schema = TableSchema::Schema.new(url)
      expect(schema[:fields].count).to eq(22)
    end

    it 'populates errors if schema is invalid and strict is false' do
      descriptor = load_descriptor('schema_invalid_pk_string.json')
      s = TableSchema::Schema.new(descriptor)
      expect(s.errors).to_not be_empty
    end

    context 'raises an exception' do

      it 'when the schema is an incorrect type' do
        descriptor = load_descriptor('schema_invalid_wrong_type.json')
        expect { TableSchema::Schema.new(descriptor) }.to raise_error(TableSchema::SchemaException, 'A schema must be a hash, path or URL')
      end

      it 'when the path does not exist' do
        expect { TableSchema::Schema.new('/some/fake/path') }.to raise_error(TableSchema::SchemaException, 'File not found at `/some/fake/path`')
      end

      it 'when the url 404s' do
        url = 'http://www.example.com/schema.json'
        stub_request(:get, url).to_return(status: 404)
        expect { TableSchema::Schema.new(url) }.to raise_error(TableSchema::SchemaException, 'URL `http://www.example.com/schema.json` returned 404 ')
      end

      it 'when the url returns invalid JSON' do
        url = 'http://www.example.com/schema.json'
        stub_request(:get, url)
                    .to_return(body: 'definitely,not,JSON')

        expect { TableSchema::Schema.new(url) }.to raise_error(TableSchema::SchemaException, 'File at `http://www.example.com/schema.json` is not valid JSON')
      end

      it 'when the schema is invalid and strict is true' do
        descriptor = load_descriptor('schema_invalid_pk_string.json')
        expect{ TableSchema::Schema.new(descriptor, strict: true) }.to raise_error(TableSchema::SchemaException)
      end

    end

    context 'cast_row' do
      let(:schema_hash) {
        {
          fields: [
              {
                  name: "id",
                  type: "string",
                  constraints: {
                      required: true,
                  }
              },
              {
                  name: "height",
                  type: "number",
                  constraints: {
                      required: false,
                  }
              },
              {
                  name: "age",
                  type: "integer",
                  constraints: {
                      required: false,
                  }
              },
              {
                  name: "name",
                  type: "string",
                  constraints: {
                      required: true,
                  }
              },
              {
                  name: "occupation",
                  type: "string",
                  constraints: {
                      required: false,
                  }
              },

          ],
          missingValues: [
            '-',
            'null',
            ''
          ]
        }
      }

      let(:schema) { TableSchema::Schema.new(schema_hash) }


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
        expect { schema.cast_row(row, fail_fast: false) }.to raise_error(
          TableSchema::MultipleInvalid,
          'There were errors parsing the data'
        )
        expect(schema.errors.count).to eq(2)
      end

    end

    context 'save' do

      it 'writes the file given as target' do
        schema = {
          fields: [
            {
              name: 'id',
              type: 'string',
              format: 'default',
              constraints: {}
            },
          ]
        }
        buffer = StringIO.new
        filename = 'my_schema.json'
        allow(File).to receive(:open).with(filename,'w').and_yield(buffer)

        s = TableSchema::Schema.new(schema)
        expect(s.save(filename)).to be true
        expect(buffer.string).to eq(JSON.pretty_generate(schema))
      end
    end

  end
end
