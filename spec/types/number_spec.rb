describe TableSchema::Types::Number do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'number',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Number.new(field) }

  it 'casts a simple number' do
    value = '10.00'
    expect(type.cast(value)).to eq(Float('10.00'))
  end

  it 'casts when the value is already cast' do
    [1, 1.0, Float(1)].each do |value|
      ['default', 'currency'].each do |format|
        field[:format] = format
        expect(type.cast(value)).to eq(Float(value))
      end
    end
  end

  it 'returns an error if the value is not a number' do
    value = 'string'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)
  end

  it 'casts with localized settings' do
    [
      '10,000.00',
      '10,000,000.23',
      '10.23',
      '1,000',
      '100%',
      '1000‰'
    ].each do |value|
      expect { type.cast(value) }.to_not raise_error
    end

    field[:groupChar] = '#'

    [
      '10#000.00',
      '10#000#000.23',
      '10.23',
      '1#000'
    ].each do |value|
      expect { type.cast(value) }.to_not raise_error
    end

    field[:decimalChar] = '@'

    [
      '10#000@00',
      '10#000#000@23',
      '10@23',
      '1#000'
    ].each do |value|
      expect { type.cast(value) }.to_not raise_error
    end

  end

  context 'currencies' do

    let(:currency_field) {
      field[:format] = 'currency'
      field
    }

    let(:currency_type) {
      TableSchema::Types::Number.new(currency_field)
    }

    it 'casts successfully' do
      [
        '10,000.00',
        '10,000,000.00',
        '$10000.00',
        '  10,000.00 €',
      ].each do |value|
        expect { currency_type.cast(value) }.to_not raise_error
      end

      field[:decimalChar] = ','
      field[:groupChar] = ' '

      [
        '10 000,00',
        '10 000 000,00',
        '10000,00 ₪',
        '  10 000,00 £',
      ].each do |value|
        expect { currency_type.cast(value) }.to_not raise_error
      end
    end

    it 'returns an error with a currency and a duff format' do
      value1 = '10,000a.00'
      value2 = '10+000.00'
      value3 = '$10:000.00'

      expect { currency_type.cast(value1) }.to raise_error(TableSchema::InvalidCast)
      expect { currency_type.cast(value2) }.to raise_error(TableSchema::InvalidCast)
      expect { currency_type.cast(value3) }.to raise_error(TableSchema::InvalidCast)
    end

  end

end
