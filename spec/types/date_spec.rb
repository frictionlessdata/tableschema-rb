describe TableSchema::Types::Date do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'date',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Date.new(field) }

  it 'casts a standard ISO8601 date string' do
    value = '2019-01-01'
    expect(type.cast(value)).to eq(Date.new(2019,01,01))
  end

  it 'returns an error for a non ISO8601 date string by default' do
    value = '29/11/2015'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidDateType)
  end

  it 'casts any parseable date' do
    value = '10th Jan 1969'
    field[:format] = 'any'
    expect(type.cast(value)).to eq(Date.new(1969,01,10))
  end

  it 'raises an error for any when date is unparsable' do
    value = '10th Jan nineteen sixty nine'
    field[:format] = 'any'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidDateType)
  end

  it 'casts with a specified date format' do
    value = '10/06/2014'
    field[:format] = 'fmt:%d/%m/%Y'
    expect(type.cast(value)).to eq(Date.new(2014,06,10))
  end

  it 'assumes the first day of the month' do
    value = '2014-06'
    field[:format] = 'fmt:%Y-%m'
    expect(type.cast(value)).to eq(Date.new(2014,06,01))
  end

  it 'raises an error for an invalid fmt' do
    value = '2014/12/19'
    field[:format] = 'fmt:DD/MM/YYYY'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidDateType)
  end

  it 'raises an error for a valid fmt and invalid value' do
    value = '2014/12/19'
    field[:format] = 'fmt:%m/%d/%y'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidDateType)
  end

  it 'works with an already cast value' do
    value = Date.new(2014,06,01)
    ['default', 'any', 'fmt:%Y-%m-%d'].each do |f|
      field[:format] = f
      expect(type.cast(value)).to eq(value)
    end
  end

end
