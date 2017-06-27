require 'spec_helper'

describe TableSchema::Infer do

  let(:filename) { @filename || "data_infer.csv" }
  let(:csv) { File.join( File.dirname(__FILE__), "fixtures", filename) }
  let(:data) {  CSV.parse(File.open csv) }
  let(:headers) { data.shift }

  it 'infers a schema' do
    inferer = TableSchema::Infer.new(headers, data)
    schema = inferer.schema

    expect(schema.get_field('id')['type']).to eq('integer')
    expect(schema.get_field('id')['format']).to eq(TableSchema::DEFAULTS['format'])

    expect(schema.get_field('age')['type']).to eq('integer')
    expect(schema.get_field('age')['format']).to eq(TableSchema::DEFAULTS['format'])

    expect(schema.get_field('name')['type']).to eq('string')
    expect(schema.get_field('name')['format']).to eq(TableSchema::DEFAULTS['format'])
  end

  it 'gets a format' do
    headers = [
      'url',
      'email',
      'currency',
      'thing'
    ]

    data = [
      ['http://example.com', 'me@example.org', '£1', 'thing'],
      ['http://example.org', 'him@example.org', '$1', 'foo'],
      ['http://example.co.uk/thing', 'them@example.com', '€5', 'thing']
    ]

    inferer = TableSchema::Infer.new(headers, data)
    schema = inferer.schema

    expect(schema.get_field('url')['type']).to eq('string')
    expect(schema.get_field('url')['format']).to eq('uri')

    expect(schema.get_field('email')['type']).to eq('string')
    expect(schema.get_field('email')['format']).to eq('email')

    expect(schema.get_field('currency')['type']).to eq('number')
    expect(schema.get_field('currency')['format']).to eq('currency')
  end

  it 'infers a schema with international characters' do
    @filename = 'data_infer_utf8.csv'

    inferer = TableSchema::Infer.new(headers, data)
    schema = inferer.schema

    expect(schema.get_field('id')['type']).to eq('integer')
    expect(schema.get_field('id')['format']).to eq(TableSchema::DEFAULTS['format'])

    expect(schema.get_field('age')['type']).to eq('integer')
    expect(schema.get_field('age')['format']).to eq(TableSchema::DEFAULTS['format'])

    expect(schema.get_field('name')['type']).to eq('string')
    expect(schema.get_field('name')['format']).to eq(TableSchema::DEFAULTS['format'])
  end

  it 'infers a schema with a row limit' do
    @filename = 'data_infer_row_limit.csv'

    inferer = TableSchema::Infer.new(headers, data, row_limit: 4)
    schema = inferer.schema

    expect(schema.get_field('id')['type']).to eq('integer')
    expect(schema.get_field('id')['format']).to eq(TableSchema::DEFAULTS['format'])

    expect(schema.get_field('age')['type']).to eq('integer')
    expect(schema.get_field('age')['format']).to eq(TableSchema::DEFAULTS['format'])

    expect(schema.get_field('name')['type']).to eq('string')
    expect(schema.get_field('name')['format']).to eq(TableSchema::DEFAULTS['format'])
  end

  it 'infers a schema with a primary key as a string' do
    inferer = TableSchema::Infer.new(headers, data, primary_key: 'id')
    schema = inferer.schema

    expect(schema.primary_keys).to eq(['id'])
  end

  it 'infers a schema with a primary key as an array' do
    inferer = TableSchema::Infer.new(headers, data, primary_key: ['id', 'age'])
    schema = inferer.schema

    expect(schema.primary_keys).to eq(['id', 'age'])
  end

  it 'lets us be explicit' do
    inferer = TableSchema::Infer.new(headers, data, explicit: true)
    schema = inferer.schema

    expect(schema.get_field('id')['constraints']).to_not be_nil
  end

  it 'lets us not be explicit' do
    inferer = TableSchema::Infer.new(headers, data, explicit: false)
    schema = inferer.schema

    expect(schema.get_field('id')['constraints']).to be_nil
  end

end
