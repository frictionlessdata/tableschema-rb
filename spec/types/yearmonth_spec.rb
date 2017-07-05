describe TableSchema::Types::YearMonth do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'yearmonth',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::YearMonth.new(field) }

  it 'casts a standard ISO8601 string' do
    positive_value = '2019-01'
    negative_value = '-2015-12'

    expect(type.cast(positive_value)).to eq({ year: 2019, month: 1 })
    expect(type.cast(negative_value)).to eq({ year: -2015, month: 12 })
  end

  it 'raises an error if the string contains invalid values ' do
    [
      '2008-30',
      '3200.6-11',
      '2017-03-12',
    ].each do |value|
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidYearMonthType)
    end
  end

  it 'casts a valid array of year and month' do
    positive_value = [1996, 9]
    negative_value = ['-0002', '04']

    expect(type.cast(positive_value)).to eq({ year: 1996, month: 9 })
    expect(type.cast(negative_value)).to eq({ year: -2, month: 4 })
  end

  it 'raises an error if the value array contains more or less values' do
    [
      [1000],
      [2019, 12, 10],
    ].each do |value|
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidYearMonthType)
    end
  end

  it 'raises an error if the value array contains invalid values' do
    [
      ['2009.5', '10'],
      [2001, 18],
    ].each do |value|
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidYearMonthType)
    end
  end
end
