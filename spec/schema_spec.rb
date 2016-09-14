require 'spec_helper'

describe JsonTableSchema::Schema do

  context 'initializes' do

    it 'with a hash' do
      hash = load_schema('schema_valid_full.json')
      schema = JsonTableSchema::Schema.new(hash)
      expect(hash).to eq(schema)
    end

    it 'with a file' do
      file = File.join( File.dirname(__FILE__), "fixtures", "schema_valid_full.json")
      schema = JsonTableSchema::Schema.new(file)
      expect(schema['fields'].count).to eq(15)
    end

    it 'with a url' do
      path = File.join( File.dirname(__FILE__), "fixtures", "schema_valid_full.json")
      url = 'http://www.example.com/schema.json'
      stub_request(:get, url)
                  .to_return(body: File.open(path))

      schema = JsonTableSchema::Schema.new(url)
      expect(schema['fields'].count).to eq(15)
    end

    context 'raises an exception' do

      it 'when the schema is an incorrect type' do
        schema = load_schema('schema_invalid_wrong_type.json')
        expect { JsonTableSchema::Schema.new(schema) }.to raise_error(JsonTableSchema::SchemaException, 'A schema must be a hash, path or URL')
      end

      it 'when the path does not exist' do
        expect { JsonTableSchema::Schema.new('/some/fake/path') }.to raise_error(JsonTableSchema::SchemaException, 'File not found at `/some/fake/path`')
      end

      it 'when the url 404s' do
        url = 'http://www.example.com/schema.json'
        stub_request(:get, url).to_return(status: 404)
        expect { JsonTableSchema::Schema.new(url) }.to raise_error(JsonTableSchema::SchemaException, 'URL `http://www.example.com/schema.json` returned 404 ')
      end

      it 'when the url returns invalid JSON' do
        url = 'http://www.example.com/schema.json'
        stub_request(:get, url)
                    .to_return(body: 'definitely,not,JSON')

        expect { JsonTableSchema::Schema.new(url) }.to raise_error(JsonTableSchema::SchemaException, 'File at `http://www.example.com/schema.json` is not valid JSON')
      end

    end

  end

end
