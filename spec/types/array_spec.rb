describe TableSchema::Types::Array do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'array',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Array.new(field) }

  it 'casts an array' do
    value = ['boo', 'ya']
    expect(type.cast(value)).to eq(value)
  end

  it 'casts JSON string' do
    value = '["boo", "ya"]'
    expect(type.cast(value)).to eq(JSON.parse(value))
  end

  it 'raises when value is not an array' do
    value = '{"key": "value"}'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidArrayType)
  end

  it 'raises when value is not JSON' do
    value = 'fdsfdsfsdfdsfdsfdsfds'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidArrayType)
  end

end
