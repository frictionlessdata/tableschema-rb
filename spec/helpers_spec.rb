require 'spec_helper'

describe JsonTableSchema::Helpers do

  let(:schema_hash) {
    {
    "fields" => [
        {
            "name" => "id",
            "type" => "string",
            "constraints" => {
              "required" => true,
            }
        },
        {
            "name" => "height",
            "type" => "number"
        }
      ]
    }
  }

  let(:schema) { JsonTableSchema::Schema.new(schema_hash) }

  it 'returns the right classes' do
    {
      'any' => 'Any',
      'array' => 'Array',
      'base' => 'Base',
      'boolean' => 'Boolean',
      'date' => 'Date',
      'datetime' => 'DateTime',
      'geojson' => 'GeoJSON',
      'geopoint' => 'GeoPoint',
      'integer' => 'Integer',
      'null' => 'Null',
      'number' => 'Number',
      'object' => 'Object',
      'string' => 'String',
      'time' => 'Time',
    }.each do |tipe, klass|
      expect(schema.get_class_for_type(tipe)).to eq("JsonTableSchema::Types::#{klass}")
    end

  end

end
