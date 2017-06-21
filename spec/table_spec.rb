require 'spec_helper'

describe TableSchema::Table do

  let(:csv) { File.join( File.dirname(__FILE__), "fixtures", "simple_data.csv") }

  let(:descriptor) { File.join( File.dirname(__FILE__), "fixtures", "schema_valid_simple.json") }

  let(:table) { TableSchema::Table.new(csv, descriptor) }

  it 'loads a schema' do
    expect(table.schema).to eq({
      "fields" => [
        {
          "name"=>"id",
          "title"=>"Identifier",
          "type"=>"integer",
          "format"=>"default"
        },
        {
          "name"=>"title",
          "title"=>"Title",
          "type"=>"string",
          "format"=>"default"
        }
      ]
    })
  end

  it 'loads a csv' do
    expect(table.rows).to eq([
      [1,'foo'],
      [2,'bar'],
      [3,'baz']
    ])
  end

  it 'accepts an array of data' do
    csv = [
      ['id','title'],
      ['4','piff'],
      ['5','paff'],
      ['6','poff']
    ]

    table = TableSchema::Table.new(csv, descriptor)

    expect(table.rows).to eq([
      [4,'piff'],
      [5,'paff'],
      [6,'poff']
    ])
  end

  it 'loads a csv from the web' do
    url = 'http://example.org/data.csv'
    stub_request(:get, url)
                .to_return(body: File.open(csv))

    table = TableSchema::Table.new(url, descriptor)
    expect(table.rows).to eq([
      [1,'foo'],
      [2,'bar'],
      [3,'baz']
    ])
  end

  it 'returns keyed rows' do
    expect(table.rows(keyed: true)).to eq([
      { 'id' => 1, 'title' => 'foo'},
      { 'id' => 2, 'title' => 'bar'},
      { 'id' => 3, 'title' => 'baz'},
    ])
  end

  it 'raises the first error by default' do
    csv = [
      ['id','title'],
      ['notnumber','piff'],
      ['5','paff'],
      ['alsonotnumber','poff']
    ]

    table = TableSchema::Table.new(csv, descriptor)

    expect { table.rows(fail_fast: true) }.to raise_error(
      TableSchema::InvalidCast,
      'notnumber is not a integer'
    )
  end

  it 'collects errors if fail_fast is set to false' do
    csv = [
      ['id','title'],
      ['notnumber','piff'],
      ['5','paff'],
      ['alsonotnumber','poff']
    ]

    table = TableSchema::Table.new(csv, descriptor)

    expect { table.rows(fail_fast: false) }.to raise_error(
      TableSchema::MultipleInvalid,
      'There were errors parsing the data'
    )

    expect(table.schema.errors.count).to eq(2)
  end

  it 'allows a limit to be set' do
    expect(table.rows(limit: 1)).to eq([
      [1,'foo']
    ])
  end

  it 'infers a schema' do
    table = TableSchema::Table.infer_schema(csv)
    expect(table.schema).to eq({
      "fields" => [
        {
          "name"=>"id",
          "title"=>"",
          "description"=>"",
          "type"=>"integer",
          "format"=>"default"
        },
        {
          "name"=>"title",
          "title"=>"",
          "description"=>"",
          "type"=>"string",
          "format"=>"default"
        }
      ]
    })
  end

end
