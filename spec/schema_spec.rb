require 'spec_helper'

describe JsonTableSchema::Schema do

  context 'initializes' do

    it 'with a hash' do
      hash = load_schema('schema_valid_full.json')
      schema = JsonTableSchema::Schema.new(hash)
      expect(hash).to eq(schema)
    end

    it 'with a file' do

    end

    it 'with a string' do

    end

  end

end
