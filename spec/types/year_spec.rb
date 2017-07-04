describe TableSchema::Types::Year do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'year',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Year.new(field) }

  it 'casts a standard ISO8601 year string' do
    positive_value = '2019'
    negative_value = '-2015'

    expect(type.cast(positive_value)).to eq(2019)
    expect(type.cast(negative_value)).to eq(-2015)
  end

  it 'casts a valid integer year' do
    positive_value = 20198
    negative_value = -2016

    expect(type.cast(positive_value)).to eq(20198)
    expect(type.cast(negative_value)).to eq(-2016)
  end

  it 'raises an error when the value is not a valid year' do
    [
      150798.6,
      'notanumber',
    ].each do |value|
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidYearType)
    end
  end
end
