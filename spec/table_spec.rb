require 'spec_helper'

describe TableSchema::Table do

  let(:csv) { File.join( File.dirname(__FILE__), "fixtures", "simple_data.csv") }

  let(:descriptor) { File.join( File.dirname(__FILE__), "fixtures", "schema_valid_simple.json") }

  let(:table) { TableSchema::Table.new(csv, schema: descriptor) }

  it 'loads a schema' do
    expect(table.schema).to eq({
      fields: [
        {
          name: "id",
          title: "Identifier",
          type: "integer",
          format: "default",
          constraints: {}
        },
        {
          name: "title",
          title: "Title",
          type: "string",
          format: "default",
          constraints: {}
        }
      ]
    })
  end

  it 'loads a csv' do
    expect(table.instance_variable_get(:@csv).map(&:fields)).to eq([
      ['1','foo'],
      ['2','bar'],
      ['3','baz']
    ])
  end

  it 'accepts an array of data' do
    csv = [
      ['id','title'],
      ['4','piff'],
      ['5','paff'],
      ['6','poff']
    ]

    table = TableSchema::Table.new(csv, schema: descriptor)

    expect(table.instance_variable_get(:@csv).map(&:fields)).to eq([
      ['4','piff'],
      ['5','paff'],
      ['6','poff']
    ])
  end

  it 'loads a csv from the web' do
    url = 'http://example.org/data.csv'
    stub_request(:get, url)
                .to_return(body: File.open(csv))

    table = TableSchema::Table.new(url, schema: descriptor)
    expect(table.instance_variable_get(:@csv).map(&:fields)).to eq([
      ['1','foo'],
      ['2','bar'],
      ['3','baz'],
    ])
  end

  context 'iterator' do

    it 'returns cast rows by default' do
      rows = []
      table.iter{|row| rows << row}

      expect(rows).to eq([
          [1,'foo'],
          [2,'bar'],
          [3,'baz'],
        ])
    end

    it 'returns keyed rows' do
      keyed_rows = []
      table.iter(keyed: true){ |row| keyed_rows << row}
      expect(keyed_rows).to eq([
        { 'id'=> 1, 'title'=> 'foo'},
        { 'id'=> 2, 'title'=> 'bar'},
        { 'id'=> 3, 'title'=> 'baz'},
      ])
    end

    it 'lets errors bubble up' do
      csv = [
        ['id','title'],
        ['notnumber','piff'],
        ['5','paff'],
      ]

      table = TableSchema::Table.new(csv, schema: descriptor)

      expect { table.iter{|row| row} }.to raise_error(
        TableSchema::InvalidCast,
        'notnumber is not a integer'
      )
    end

    it 'allows a limit to be set' do
      rows = []
      table.iter(limit: 1){ |row| rows << row }
      expect(rows).to eq([
        [1,'foo']
      ])
    end

    it 'returns an iterator without a block' do
      table = TableSchema::Table.new(csv, schema: descriptor)
      iter = table.iter(keyed: true)

      expect(iter.take(1)).to eq([
        { 'id'=> 1, 'title'=> 'foo' }
      ])
    end

  end

  context 'read' do

    it 'returns cast rows by default' do
      expect(table.read).to eq([
          [1,'foo'],
          [2,'bar'],
          [3,'baz'],
        ])
    end

    it 'returns keyed rows' do
      expect(table.read(keyed: true)).to eq([
        { 'id'=> 1, 'title'=> 'foo'},
        { 'id'=> 2, 'title'=> 'bar'},
        { 'id'=> 3, 'title'=> 'baz'},
      ])
    end

  end

  it 'infers a schema' do
    table = TableSchema::Table.new(csv)
    table.infer()
    expect(table.schema).to eq({
      fields: [
        {
          name: "id",
          title: "",
          description: "",
          type: "integer",
          format: "default",
          constraints: {}
        },
        {
          name: "title",
          title: "",
          description: "",
          type: "string",
          format: "default",
          constraints: {}
        }
      ]
    })
  end

  it 'saves to a file' do
    output_file = StringIO.new()
    filename = 'output.csv'
    allow(CSV).to receive(:open).with(filename,'wb', {headers: true}).and_yield(output_file)

    expect(table.save(filename)).to be true
  end

end
