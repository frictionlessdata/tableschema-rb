require 'spec_helper'

describe TableSchema::Model do

  let(:descriptor) {
    {
      fields: [
          {
              name: "id",
              type: "string",
              constraints: {
                  required: true,
              }
          },
          {
              name: "height",
              type: "number",
              constraints: {
                  required: false,
              }
          },
          {
              name: "age",
              type: "integer",
              constraints: {
                  required: false,
              }
          },
          {
              name: "name",
              type: "string",
              constraints: {
                  required: true,
              }
          },
          {
              name: "occupation",
              type: "string",
              constraints: {
                  required: false,
              }
          },

      ]
    }
  }

  let(:schema_min) {
    {
      fields: [
          {
              name: "id"
          },
          {
              name: "height"
          }
      ]
    }
  }

  it "returns headers" do
    s = TableSchema::Schema.new(descriptor)
    expect(s.headers.count).to eq(5)
  end

  it "returns required headers" do
    s = TableSchema::Schema.new(descriptor)
    expect(s.required_headers.count).to eq(2)
  end

  context "check for field presence" do

    it "returns true" do
      s = TableSchema::Schema.new(descriptor)
      expect(s.has_field?('name')).to be true
    end

    it "returns false" do
      s = TableSchema::Schema.new(descriptor)
      expect(s.has_field?('religion')).to be false
    end

  end

  it "gets fields by type" do
    s = TableSchema::Schema.new(descriptor)

    expect(s.get_fields_by_type('string').count).to eq(3)
    expect(s.get_fields_by_type('number').count).to eq(1)
    expect(s.get_fields_by_type('integer').count).to eq(1)
  end

  context 'get type' do

    it 'gets the type of a field' do
      s = TableSchema::Schema.new(descriptor)
      expect(s.get_type('id')).to eq('string')
    end

    it 'gets a default type' do
      s = TableSchema::Schema.new(schema_min)
      expect(s.get_type('id')).to eq('string')
    end

  end

  context 'get constraints' do

    it 'gets the constraints for a field' do
      s = TableSchema::Schema.new(descriptor)
      expect(s.get_constraints('id')).to eq({required: true})
    end

    it 'returns an empty hash where there are no constraints' do
      s = TableSchema::Schema.new(schema_min)
      expect(s.get_constraints('id')).to eq({})
    end

  end

  context 'case insensitive headers' do

    let(:new_descriptor) {
      new_descriptor = descriptor.dup
      new_descriptor[:fields].map { |f| f[:name].capitalize! }
      new_descriptor
    }

    it 'with headers' do
      s = TableSchema::Schema.new(new_descriptor, case_insensitive_headers: true)
      expect(s.headers).to eq(['id', 'height', 'age', 'name', 'occupation'])
    end

    it 'with required' do
      s = TableSchema::Schema.new(new_descriptor, case_insensitive_headers: true)
      expect(s.required_headers).to eq(['id', 'name'])
    end

  end

  it 'sets defaults' do
    s = TableSchema::Schema.new(schema_min)
    expect(s.get_fields_by_type('string').count).to eq(2)
  end

  it 'does not set fields as required by default' do
     hash = {
       fields: [
        {name: "id", constraints: {required: true}},
        {name: "label"}
       ]
     }

     s = TableSchema::Schema.new(hash)
     expect(s.required_headers.count).to eq(1)
  end

  context 'add field' do

    it 'adds a field if it passes validation' do
      s = TableSchema::Schema.new(descriptor)
      field = { name: 'phone' }

      expect(s.add_field(field)).to eq(field)
      expect(s.fields.last).to eq(field)
    end

    it 'doesn\'t add field if it fails validation' do
      s = TableSchema::Schema.new(descriptor)
      field = { title: 'Name is mandatory' }
      initial_fields = s.fields

      expect(s.add_field(field)).to eq(nil)
      expect(s.fields).to eq(initial_fields)
    end

    it 'raises error if updated schema is invalid and strict is true' do
      s = TableSchema::Schema.new(descriptor, strict: true)
      field = { title: 'Name is mandatory' }

      expect{ s.add_field(field) }.to raise_error(TableSchema::SchemaException)
    end

  end

  context 'remove field' do

    it 'removes field by name' do
      s = TableSchema::Schema.new(descriptor)
      initial_fields_size = s.fields.size
      field = {
          name: "age",
          type: "integer",
          constraints: {
              required: false,
          },
          format: "default",
      }

      expect(s.remove_field('age')).to eq(field)
      expect(s.fields.size).to eq(initial_fields_size - 1)
    end

  end

  context 'primary key' do

    it 'returns a single primary key as an array' do
      descriptor = load_descriptor('schema_valid_pk_string.json')
      s = TableSchema::Schema.new(descriptor)
      expect(s.primary_key).to eq(['id'])
    end

    it 'returns the primary key as an array' do
      descriptor = load_descriptor('schema_valid_pk_array.json')
      s = TableSchema::Schema.new(descriptor)
      expect(s.primary_key).to eq(['id', 'title'])
    end

    it 'returns an empty array if there is no primary key' do
      s = TableSchema::Schema.new(schema_min)
      expect(s.primary_key).to eq([])
    end

  end

  context 'foreign key' do

    it 'with a valid foreign key string' do
      descriptor = load_descriptor('schema_valid_fk_string.json')
      schema = TableSchema::Schema.new(descriptor)
      expect(schema.foreign_keys).to eq([
        {
            fields: "state",
            reference: {
                datapackage: "http://data.okfn.org/data/mydatapackage/",
                resource: "the-resource",
                fields: "state_id"
            }
        }
      ])
    end

    it 'with a valid foreign key self reference' do
      descriptor = load_descriptor('schema_valid_fk_string_self_referencing.json')
      schema = TableSchema::Schema.new(descriptor)
      expect(schema.foreign_keys).to eq([
        {
            fields: "parent",
            reference: {
                datapackage: "",
                resource: "self",
                fields: "id"
            }
        }
      ])
    end

    it 'with a valid foreign key array' do
      descriptor = load_descriptor('schema_valid_fk_array.json')
      schema = TableSchema::Schema.new(descriptor)
      expect(schema.foreign_keys).to eq([
          {
              fields: ["id", "title"],
              reference: {
                  datapackage: "http://data.okfn.org/data/mydatapackage/",
                  resource: "the-resource",
                  fields: ["fk_id", "title_id"]
              }
          }
      ])
    end

    it 'returns an empty array if there is no foreign key' do
      s = TableSchema::Schema.new(schema_min)
      expect(s.foreign_keys).to eq([])
    end

  end

end
