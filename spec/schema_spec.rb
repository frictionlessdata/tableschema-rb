require 'spec_helper'

describe TableSchema::Schema do

  context 'initializes' do

    it 'with a hash' do
      hash = load_descriptor('schema_valid_full.json')
      schema = TableSchema::Schema.new(hash)
      expect(schema['fields'].count).to eq(22)
      expect(schema['fields'].first.class).to eq(TableSchema::Field)
    end

    it 'with a file' do
      file = File.join( File.dirname(__FILE__), "fixtures", "schema_valid_full.json")
      schema = TableSchema::Schema.new(file)
      expect(schema['fields'].count).to eq(22)
    end

    it 'with a url' do
      path = File.join( File.dirname(__FILE__), "fixtures", "schema_valid_full.json")
      url = 'http://www.example.com/schema.json'
      stub_request(:get, url)
                  .to_return(body: File.open(path))

      schema = TableSchema::Schema.new(url)
      expect(schema['fields'].count).to eq(22)
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

    end

  end

end
