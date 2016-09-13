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
      expect(schema).to eq load_schema('schema_valid_full.json')
    end

    it 'with a url' do
      path = File.join( File.dirname(__FILE__), "fixtures", "schema_valid_full.json")
      url = 'http://www.example.com/schema.json'
      stub_request(:get, url)
                  .to_return(body: File.open(path))

      schema = JsonTableSchema::Schema.new(url)
      expect(schema).to eq load_schema('schema_valid_full.json')
    end

  end

end
