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
      expect(type.cast(value)).to eq(Float(value))
    end
  end

  it 'returns an error if the value is not a number' do
    value = 'string'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)
  end

  it 'casts exponent' do
    value = '10E1'
    expect(type.cast(value)).to eq(Float(100))
  end

  it 'allows special strings' do
    nan = 'NaN'
    neg_infinity = '-INF'
    infinity = 'INF'

    expect(type.cast(nan).nan?).to eq(true)
    expect(type.cast(neg_infinity).infinite?).to eq(-1)
    expect(type.cast(infinity).infinite?).to eq(1)
  end

  context 'custom settings' do

    it 'casts according default char settings' do
      [
        '10,000.00',
        '10,000,000.23',
        '10.23',
        '1,000'
      ].each do |value|
        expect { type.cast(value) }.to_not raise_error
      end
    end

    it 'casts according to custom groupChar and decimalChar' do
      field[:groupChar] = '#'
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

    it 'casts if bareNumber is false' do
      field[:bareNumber] = false
      [
        '$100M',
        '  100 $',
        '100%',
      ].each do |value|
        expect(type.cast(value)).to eq(Float(100))
      end

    end

  end

end
