require 'spec_helper'

describe TableSchema::Table do

  let(:csv) { File.join( File.dirname(__FILE__), "fixtures", "simple_data.csv") }

  let(:descriptor) { File.join( File.dirname(__FILE__), "fixtures", "schema_valid_simple.json") }

  let(:table) { TableSchema::Table.new(csv, descriptor) }

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

    table = TableSchema::Table.new(csv, descriptor)

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

    table = TableSchema::Table.new(url, descriptor)
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

    it 'raises the first error by default' do
      csv = [
        ['id','title'],
        ['notnumber','piff'],
        ['5','paff'],
        ['alsonotnumber','poff']
      ]

      table = TableSchema::Table.new(csv, descriptor)

      expect { table.iter(fail_fast: true) {|row| row} }.to raise_error(
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

      expect { table.iter(fail_fast: false) {|row| row} }.to raise_error(
        TableSchema::MultipleInvalid,
        'There were errors parsing the data'
      )

      expect(table.schema.errors.count).to eq(2)
    end

    it 'allows a limit to be set' do
      rows = []
      table.iter(row_limit: 1){ |row| rows << row }
      expect(rows).to eq([
        [1,'foo']
      ])
    end

    it 'returns an iterator without a block' do
      table = TableSchema::Table.new(csv, descriptor)
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

    it 'raises the first error by default' do
      csv = [
        ['id','title'],
        ['notnumber','piff'],
        ['5','paff'],
        ['alsonotnumber','poff']
      ]

      table = TableSchema::Table.new(csv, descriptor)

      expect { table.read(fail_fast: true) }.to raise_error(
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

      expect { table.read(fail_fast: false) }.to raise_error(
        TableSchema::MultipleInvalid,
        'There were errors parsing the data'
      )

      expect(table.schema.errors.count).to eq(2)
    end

    it 'allows a limit to be set' do
      expect(table.read(row_limit: 1)).to eq([
        [1,'foo']
      ])
    end

  end

  it 'infers a schema' do
    table = TableSchema::Table.infer_schema(csv)
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

end
