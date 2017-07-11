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

      expect(table.errors.count).to eq(2)
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

      expect(table.errors.count).to eq(2)
    end

    it 'allows a limit to be set' do
      expect(table.read(row_limit: 1)).to eq([
        [1,'foo']
      ])
    end

  end

  context 'unique_columns' do

    let(:schema) { TableSchema::Schema.new(descriptor) }

    before(:each) {
      schema.fields.first[:constraints][:unique] = true
    }

    it 'collects values for unique_columns' do
      table = TableSchema::Table.new(csv, schema.to_h)

      table.iter{|row| row}
      expect(table.instance_variable_get(:@unique_columns)).to eq({
         'id'=> [1, 2, 3]
      })
    end

    it 'passes unique_columns to unique constraint' do
      duplicated_csv = [
        ['id', 'title'],
        ['1', 'foo'],
        ['2', 'bar'],
        ['2', 'baz'],
      ]
      table = TableSchema::Table.new(duplicated_csv, schema.to_h)

      expect{ table.iter{|row| row} }.to raise_error(TableSchema::ConstraintError, "The value for the field `id` should be unique")
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
            },
        ],
        missingValues: [
          'null',
        ]
      }
    }

    let(:csv_array) {
      [['string', '10.0', '1']]
    }

    let(:table) { TableSchema::Table.new(csv_array, schema_hash) }

    it 'converts row values' do
      row = csv_array.first
      expect(table.cast_row(row)).to eq(['string', Float(10.0), 1])
    end

    it 'converts a row with null values' do
      row = ['string', 'null', '5']
      expect(table.cast_row(row)).to eq(['string', nil, 5])
    end

    it 'raises an error for a row with too few items' do
      row = ['string', '10.0']
      expect { table.cast_row(row) }.to raise_error(
        TableSchema::ConversionError,
        "The number of items to convert (#{row.count}) does not match the number of headers in the schema (#{schema_hash[:fields].count})"
      )
    end

    it 'raises an error for a row with too many items' do
      row = ['string', '10.0', '1', 'string']
      expect { table.cast_row(row) }.to raise_error(
        TableSchema::ConversionError,
        "The number of items to convert (#{row.count}) does not match the number of headers in the schema (#{schema_hash[:fields].count})"
      )
    end

    it 'raises an error if a column has the wrong type' do
      row = ['string', 'notdecimal', '10.6']
      expect { table.cast_row(row) }.to raise_error(
        TableSchema::InvalidCast,
        'notdecimal is not a number'
      )
    end

    it 'raises multiple errors if fail_fast is set to false' do
      row = ['string', 'notdecimal', '10.6']
      expect { table.cast_row(row, fail_fast: false) }.to raise_error(
        TableSchema::MultipleInvalid,
        'There were errors parsing the data'
      )
      expect(table.errors.count).to eq(2)
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
