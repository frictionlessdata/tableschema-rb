describe TableSchema::Types::GeoPoint do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'geopoint',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::GeoPoint.new(field) }

  it 'handles a simple point string' do
    value = '10.0, 21.00'
    expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
  end

  it 'raises an error for points outside of the longitude range' do
    value = '310.0, 921.00'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
  end

  it 'raises an error for points outside of the latitude range' do
    value = '10.0, 921.00'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
  end

  it 'raises for something that is not a geopoint' do
    value = 'this is not a geopoint'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
  end

  it 'raises for non decimal values' do
    value = 'blah, blah'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
  end

  it 'raises for wrong length of points' do
    value = '10.0, 21.00, 1'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
  end

  it 'handles an array' do
    field[:format] = 'array'
    value = [10.0, 21.00]
    expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
    value = ["10.0", "21.00"]
    expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
  end

  it 'handles an array as a JSON string' do
    field[:format] = 'array'
    value = '[10.0, 21.00]'
    expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
  end

  it 'raises for an invalid array' do
    field[:format] = 'array'
    value = '1,2'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
    value = '["a", "b"]'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
    value = '1,2'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
  end

  it 'handles an object' do
    field[:format] = 'object'
    value = {longitude: "10.0", latitude: "21.00"}
    expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
    value = {longitude: "10.0", latitude: "21.00"}
    expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
  end

  it 'handles an object as a JSON string' do
    field[:format] = 'object'
    value = '{"longitude": "10.0", "latitude": "21.00"}'
    expect(type.cast(value)).to eq([Float(10.0), Float(21.00)])
  end

  it 'raises for an invalid object' do
    field[:format] = 'object'
    value = '{"blah": "10.0", "latitude": "21.00"}'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
    value = '{"longitude": "a", "latitude": "21.00"}'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoPointType)
  end

end
