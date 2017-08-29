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
    value = 'true'
    expect(type.cast(value)).to be true
  end

  it 'casts a simple false value' do
    value = 'false'
    expect(type.cast(value)).to be false
  end

  it 'casts truthy values' do
    ['true', 'True', 'TRUE', '1', true].each do |value|
      expect(type.cast(value)).to be true
    end
  end

  it 'casts falsy values' do
    ['false', 'False', 'FALSE', '0', false].each do |value|
      expect(type.cast(value)).to be false
    end
  end

  it 'raises for invalid values' do
    value = 'not a true value'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)

    value = 11231902333
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)
  end

  context 'custom true/falseValues' do

    let(:field) {
      TableSchema::Field.new({
        name: 'Name',
        type: 'boolean',
        trueValues: ['Y', 'Yes'],
        falseValues: ['N', 'No'],
      })
    }

    let(:type) { TableSchema::Types::Boolean.new(field) }

    it 'casts truthy values' do
      p field.descriptor
      ['Y', 'Yes', true].each do |value|
        expect(type.cast(value)).to be true
      end
    end

    it 'casts falsy values' do
      ['N', 'No', false].each do |value|
        expect(type.cast(value)).to be false
      end
    end

    it 'raises for invalid values' do
      value = 'true'
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)
      value = 'false'
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)
    end

  end

end
