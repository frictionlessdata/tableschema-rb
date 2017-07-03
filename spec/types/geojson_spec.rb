describe TableSchema::Types::GeoJSON do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'geojson',
      format: 'default',
      constraints: {
        required: false
      }
    })
  }

  let(:type) { TableSchema::Types::GeoJSON.new(field) }

  it 'raises with invalid GeoJSON' do
    value = {coordinates: [0, 0, 0], type:'Point'}
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoJSONType)
  end

  it 'handles a GeoJSON hash' do
    value = {
      properties: {
        Ã: "Ã"
      },
      type: "Feature",
      geometry: nil,
    }

    expect(type.cast(value)).to eq(value)
  end

  it 'handles a GeoJSON string' do
    value = '{"geometry": null, "type": "Feature", "properties": {"\\u00c3": "\\u00c3"}}'

    expect(type.cast(value)).to eq(JSON.parse(value, symbolize_names: true))
  end

  it 'raises with an invalid JSON string' do
    value = 'notjson'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidGeoJSONType)
  end

  it 'casts to none if string is blank' do
    value = ''
    # Required is false so cast null value to nil
    expect(type.cast(value)).to eq(nil)
  end

end
