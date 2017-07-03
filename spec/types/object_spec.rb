describe TableSchema::Types::Object do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'object',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Object.new(field) }

  it 'casts a hash' do
    value = {key: 'value'}
    expect(type.cast(value)).to eq(value)
  end

  it 'casts JSON string' do
    value = '{"key": "value"}'
    expect(type.cast(value)).to eq(JSON.parse(value, symbolize_names: true))
  end

  it 'raises when value is not a hash' do
    value = ['boo', 'ya']
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidObjectType)
  end

  it 'raises when value is not JSON' do
    value = 'fdsfdsfsdfdsfdsfdsfds'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidObjectType)
  end

end
