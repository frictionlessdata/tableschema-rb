describe TableSchema::Types::Time do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'time',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Time.new(field) }

  it 'casts a standard ISO8601 time string' do
    value = '06:00:00'
    expect(type.cast(value)).to eq(Tod::TimeOfDay.new(6,0))
  end

  it 'raises an error when the string is not iso8601' do
    value = '3 am'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidTimeType)
  end

  it 'parses a generic time string' do
    value = '3:00 am'
    field[:format] = 'any'
    expect(type.cast(value)).to eq(Tod::TimeOfDay.new(3,0))
  end

  it 'raises when a time string is invalid' do
    value = 'Flava Flav'
    field[:format] = 'any'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidTimeType)
  end

  it 'raises an error when type format is incorrect' do
    value = 3.00
    self.field[:format] = 'fmt:any'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidTimeType)

    value = {}
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidTimeType)

    value = []
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidTimeType)
  end

  it 'works with an already cast value' do
    value = Tod::TimeOfDay.new(06,00)
    ['default', 'any', 'fmt:any'].each do |f|
      field[:format] = f
      expect(type.cast(value)).to eq(value)
    end
  end

end
