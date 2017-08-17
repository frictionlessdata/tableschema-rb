require 'spec_helper'

describe TableSchema::Validate do

  context 'simple validation' do

    context 'returns true' do

      it 'with a simple schema' do
        descriptor = load_descriptor('schema_valid_simple.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(true)
        expect(schema.validate!).to eq(true)
      end

      it 'with a full schema' do
        descriptor = load_descriptor('schema_valid_full.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(true)
        expect(schema.validate!).to eq(true)
      end

    end

    context 'returns false' do

      it 'with an empty schema' do
        descriptor = load_descriptor('schema_invalid_empty.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
        expect{ schema.validate! }.to raise_error(TableSchema::SchemaException)
      end

    end

    it 'updates errors at each validation' do
      schema_hash = {
        fields: [
          {
            name: 'id',
            title: 'Identifier',
            type: 'integer'
          },
          {
            name: 'title',
            title: 'Title',
            type: 'nonexistent'
          },
        ],
      }
      schema = TableSchema::Schema.new(schema_hash)
      expect(schema.errors).to_not be_empty

      schema.remove_field('title')
      expect(schema.errors).to be_empty
    end

  end

  context 'primary keys' do

    context 'returns true' do

      it 'with a primary key as a string' do
        descriptor = load_descriptor('schema_valid_pk_string.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(true)
      end

      it 'with a primary key as an array' do
        descriptor = load_descriptor('schema_valid_pk_array.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(true)
      end

    end

    context 'returns false' do

      it 'when primary key string value is wrong' do
        descriptor = load_descriptor('schema_invalid_pk_string.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
      end

      it 'when primary key array value is wrong' do
        descriptor = load_descriptor('schema_invalid_pk_array.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
      end

      it 'when the primary key is not a valid type' do
        descriptor = load_descriptor('schema_invalid_pk_is_wrong_type.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
      end

      it 'when the schema has no fields' do
        descriptor = load_descriptor('schema_invalid_pk_no_fields.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
        expect(schema.errors.count).to eq(3)
      end

    end

  end

  context 'foreign keys' do

    context 'returns true' do

      it 'with a valid foreign key string' do
        descriptor = load_descriptor('schema_valid_fk_string.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(true)
      end

      it 'with a valid foreign key self reference' do
        descriptor = load_descriptor('schema_valid_fk_string_self_referencing.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(true)
      end

      it 'with a valid foreign key array' do
        descriptor = load_descriptor('schema_valid_fk_array.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(true)
      end

    end

    context 'returns false' do

      it 'with an invalid foreign key string' do
        descriptor = load_descriptor('schema_invalid_fk_string.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
      end

      it 'with an invalid foreign key array' do
        descriptor = load_descriptor('schema_invalid_fk_array.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
      end

      it 'where foreign key reference is an array and fields are a string' do
        descriptor = load_descriptor('schema_invalid_fk_string_array_ref.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
      end

      it 'where foreign key reference is an string and fields are an array' do
        descriptor = load_descriptor('schema_invalid_fk_string_array_ref.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
      end

      it 'where there is a foreign key reference and field count mismatch' do
        descriptor = load_descriptor('schema_invalid_fk_array_wrong_number.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
      end

      it 'where the resource is empty and the fields miss from headers' do
        descriptor = load_descriptor('schema_invalid_fk_no_resource.json')
        schema = TableSchema::Schema.new(descriptor)
        expect(schema.validate).to eq(false)
      end
    end

  end

end
