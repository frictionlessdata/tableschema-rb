describe TableSchema::Types::Boolean do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'boolean',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Boolean.new(field) }

  it 'casts a simple true value' do
    value = 't'
    expect(type.cast(value)).to be true
  end

  it 'casts a simple false value' do
    value = 'f'
    expect(type.cast(value)).to be false
  end

  it 'casts truthy values' do
    ['yes', 1, 't', 'true', true].each do |value|
      expect(type.cast(value)).to be true
    end
  end

  it 'casts falsy values' do
    ['no', 0, 'f', 'false', false].each do |value|
      expect(type.cast(value)).to be false
    end
  end

  it 'raises for invalid values' do
    value = 'not a true value'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)

    value = 11231902333
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)
  end

end
