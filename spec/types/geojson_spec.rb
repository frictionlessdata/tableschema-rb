describe TableSchema::Types::GeoJSON do
  context 'GeoJSON' do

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

    it 'raises with invalid GeoJSON' do
      value = {coordinates: [0, 0, 0], type:'Point'}
        expect { field.cast_type(value) }.to raise_error(TableSchema::InvalidGeoJSONType)
    end

    it 'handles a GeoJSON hash' do
      value = {
        properties: {
          Ã: "Ã"
        },
        type: "Feature",
        geometry: nil,
      }

      expect(field.cast_type(value)).to eq(value)
    end

    it 'handles a GeoJSON string' do
      value = '{"geometry": null, "type": "Feature", "properties": {"\\u00c3": "\\u00c3"}}'

      expect(field.cast_type(value)).to eq(JSON.parse(value, symbolize_names: true))
    end

    it 'raises with an invalid JSON string' do
      value = 'notjson'
      expect { field.cast_type(value) }.to raise_error(TableSchema::InvalidGeoJSONType)
    end

    it 'casts to none if string is blank' do
      value = ''
      # Required is false so cast null value to nil
      expect(field.cast_type(value)).to eq(nil)
    end

  end

  context 'TopoJSON' do

    let(:field) {
      TableSchema::Field.new({
        name: 'Name',
        type: 'geojson',
        format: 'topojson',
        constraints: {
          required: false
        }
      })
    }

    let(:type) { TableSchema::Types::GeoJSON.new(field) }

    it 'raises with invalid TopoJSON' do
      value = {
        type:'Point',
        geometries: [
          {
            type: 'InvalidGeometry'
          }
        ]
      }
      expect { field.cast_type(value) }.to raise_error(TableSchema::InvalidTopoJSONType)
    end

    let(:topohash) {
      {
        type: "Topology",
        arcs: [
          [[102, 0], [103, 1], [104, 0], [105, 1]],
          [[100, 0], [101, 0], [101, 1], [100, 1], [100, 0]]
        ],
        objects: {
          mygeometry: {
            id: 1,
            type: "Point",
            coordinates: [4000, 5000]
          }
        }
      }
    }

    it 'handles a TopoJSON hash' do
      expect(field.cast_type(topohash)).to eq(topohash)
    end

    it 'handles a TopoJSON string' do
      expect(field.cast_type(topohash.to_json)).to eq(topohash)
    end

    it 'raises with invalid TopoJSON string' do
      value = 'notaTopoJSON'
      expect { field.cast_type(value) }.to raise_error(TableSchema::InvalidTopoJSONType)
    end

  end
end
