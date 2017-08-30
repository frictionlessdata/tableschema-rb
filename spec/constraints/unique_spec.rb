require 'spec_helper'

  describe TableSchema::Constraints::Unique do

    let(:schema_hash) {
        {
          fields: [
              {
                  name: "id",
                  type: "string",
                  constraints: {
                      unique: true,
                  }
              },
              {
                  name: "height",
                  type: "number",
                  constraints: {
                      unique: false,
                  }
              }
          ]
        }
    }

    let(:schema) {TableSchema::Schema.new(schema_hash)}

    let(:csv) { [['id', 'height']].concat(@rows) }

    let(:table) { TableSchema::Table.new(csv, schema: schema.to_h) }

    context 'with string type' do

      before(:each) do
        schema[:fields].first[:type] = 'string'
        @unique_field = schema[:fields].first[:name]
        @value = 'foo'
      end

      it 'handles a valid value' do
        @rows = [
          [@value, 2.5],
        ]
        expect(table.read).to eq(@rows)
      end

      it 'handles an invalid value' do
        @rows = [
          [@value, 2.5],
          [@value, 3.8],
        ]
        expect { table.read }.to raise_error(TableSchema::ConstraintError,
          "The values for the field `#{@unique_field}` should be unique but value `#{@value}` is repeated")
      end
    end

    context 'with integer type' do

      before(:each) do
        schema[:fields].first[:type] = 'integer'
        @unique_field = schema[:fields].first[:name]
        @value = 1
      end

      it 'handles with a valid value' do
        @rows = [
          [@value, 3.7],
        ]
        expect( table.read ).to eq(@rows)
      end

      it 'handles with an invalid value' do
        @rows = [
          [@value, 3.7],
          [@value, 7.4],
        ]
        expect { table.read }.to raise_error(TableSchema::ConstraintError,
          "The values for the field `#{@unique_field}` should be unique but value `#{@value}` is repeated")
      end

    end

    context 'with number type' do

      before(:each) do
        schema[:fields].first[:type] = 'number'
        @unique_field = schema[:fields].first[:name]
        @value = 2.4
      end

      it 'handles with a valid value' do
        @rows = [
          [@value, 3.7],
        ]
        expect( table.read ).to eq(@rows)
      end

      it 'handles with an invalid value' do
        @rows = [
          [@value, 3.7],
          [@value, 7.4],
        ]
        expect { table.read }.to raise_error(TableSchema::ConstraintError,
          "The values for the field `#{@unique_field}` should be unique but value `#{@value}` is repeated")
      end

    end

    context 'with array type' do

      before(:each) do
        schema[:fields].first[:type] = 'array'
        @unique_field = schema[:fields].first[:name]
        @value = ['a', 'b', 'c']
      end

      it 'handles with a valid value' do
        @rows = [
          [@value, 2.6],
        ]
        expect( table.read ).to eq(@rows)
      end

      it 'handles with an invalid value' do
        @rows = [
          [@value, 2.6],
          [@value, 2.6],
        ]
        expect { table.read }.to raise_error(TableSchema::ConstraintError,
          "The values for the field `#{@unique_field}` should be unique but value `#{@value}` is repeated")
      end

    end

    context 'with object type' do

      before(:each) do
        schema_hash[:fields].first[:type] = 'object'
        @unique_field = schema.fields.first
        @value = '{"a": 1, "b": 2, "c": 3}'
        @cast_value = @unique_field.cast_type(@value)
      end

      it 'handles with a valid value' do
        @rows = [
          [@value, 2.6],
        ]
        expect( table.read ).to eq([
          [@cast_value, 2.6],
        ])
      end

      it 'handles with an invalid value' do
        @rows = [
          [@value, 2.6],
          [@value, 2.6],
        ]
        expect { table.read }.to raise_error(TableSchema::ConstraintError,
          "The values for the field `#{@unique_field[:name]}` should be unique but value `#{@cast_value}` is repeated")
      end

    end

    context 'with date type' do

      before(:each) do
        schema_hash[:fields].first[:type] = 'date'
        @unique_field = schema.fields.first
        @value = '2015-01-23'
        @cast_value = @unique_field.cast_type(@value)
      end

      it 'handles with a valid value' do
        @rows = [
          [@value, 2.6],
        ]
        expect( table.read ).to eq([
          [@cast_value, 2.6],
        ])
      end

      it 'handles with an invalid value' do
        @rows = [
          [@value, 2.6],
          [@value, 2.6],
        ]
        expect { table.read }.to raise_error(TableSchema::ConstraintError,
          "The values for the field `#{@unique_field[:name]}` should be unique but value `#{@cast_value}` is repeated")
      end

    end

  end
