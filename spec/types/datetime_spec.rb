describe TableSchema::Types::DateTime do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'datetime',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::DateTime.new(field) }

  it 'casts a standard ISO8601 date string' do
    value = '2019-01-01T02:00:00Z'
    expect(type.cast(value)).to eq(DateTime.new(2019,01,01,2,0,0))
  end

  it 'guesses when fomat is any' do
    value = '10th Jan 1969 9am'
    field[:format] = 'any'
    expect(type.cast(value)).to eq(DateTime.new(1969,01,10,9,0,0))
  end

  it 'accepts a specified format' do
    value = '21/11/06 16:30'
    field[:format] = 'fmt:%d/%m/%y %H:%M'
    expect(type.cast(value)).to eq(DateTime.new(2006,11,21,16,30,00))
  end

  it 'fails with a non iso datetime by default' do
    value = 'Mon 1st Jan 2014 9 am'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidDateTimeType)
  end

  it 'raises an exception for an unparsable datetime' do
    value = 'the land before time'
    field[:format] = 'any'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidDateTimeType)
  end

  it 'raises if the date format is invalid' do
    value = '21/11/06 16:30'
    field[:format] = 'fmt:notavalidformat'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidDateTimeType)
  end

  it 'works fine with an already cast value' do
    value = DateTime.new(2015, 1, 1, 12, 0, 0)
    ['default', 'any', 'fmt:any'].each do |format|
      field[:format] = format
      expect(type.cast(value)).to eq(value)
    end
  end

end
