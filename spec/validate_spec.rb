require 'spec_helper'

describe JsonTableSchema::Validate do

  context 'simple validation' do

    context 'returns true' do

      it 'with a simple schema' do
        schema = load_schema('schema_valid_simple.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(true)
      end

      it 'with a full schema' do
        schema = load_schema('schema_valid_full.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(true)
      end

    end

    context 'returns false' do

      it 'with an empty schema' do
        schema = load_schema('schema_invalid_empty.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

      # it 'with a wrong type' do
      #   schema = load_schema('schema_invalid_wrong_type.json')
      #   schema = JsonTableSchema::Schema.new(schema)
      #   expect(schema.valid?).to eq(false)
      # end

    end

  end

  context 'primary keys' do

    context 'returns true' do

      it 'with a primary key as a string' do
        schema = load_schema('schema_valid_pk_string.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(true)
      end

      it 'with a primary key as an array' do
        schema = load_schema('schema_valid_pk_array.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(true)
      end

    end

    context 'returns false' do

      it 'when primary key string value is wrong' do
        schema = load_schema('schema_invalid_pk_string.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

      it 'when primary key array value is wrong' do
        schema = load_schema('schema_invalid_pk_array.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

      it 'when the primary key is not a valid type' do
        schema = load_schema('schema_invalid_pk_is_wrong_type.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

      it 'when the schema has no fields' do
        schema = load_schema('schema_invalid_pk_no_fields.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
        expect(schema.messages.count).to eq(3)
      end

    end

  end

  context 'foreign keys' do

    context 'returns true' do

      it 'with a valid foreign key string' do
        schema = load_schema('schema_valid_fk_string.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(true)
      end

      it 'with a valid foreign key self reference' do
        schema = load_schema('schema_valid_fk_string_self_referencing.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(true)
      end

      it 'with a valid foreign key array' do
        schema = load_schema('schema_valid_fk_array.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(true)
      end

    end

    context 'returns false' do

      it 'with an invalid foreign key string' do
        schema = load_schema('schema_invalid_fk_string.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

      it 'with a foreign key with no reference' do
        schema = load_schema('schema_invalid_fk_no_reference.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

      it 'with an invalid foreign key array' do
        schema = load_schema('schema_invalid_fk_array.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

      it 'where foreign key reference is an array and fields are a string' do
        schema = load_schema('schema_invalid_fk_string_array_ref.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

      it 'where foreign key reference is an string and fields are an array' do
        schema = load_schema('schema_invalid_fk_string_array_ref.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

      it 'where there is a foreign key reference and field count mismatch' do
        schema = load_schema('schema_invalid_fk_array_wrong_number.json')
        schema = JsonTableSchema::Schema.new(schema)
        expect(schema.valid?).to eq(false)
      end

    end

  end

end
