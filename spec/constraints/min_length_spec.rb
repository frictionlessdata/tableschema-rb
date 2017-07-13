require 'spec_helper'

describe TableSchema::Constraints::MinLength do

  let(:field_attrs) {
    {
      name: 'Name',
      format: 'default',
      constraints: {}
    }
  }

  let(:field) { TableSchema::Field.new(field_attrs)}

  let(:constraints) { TableSchema::Constraints.new(field, @value) }

  context 'with string type' do

    before(:each) do
      field_attrs[:type] = 'string'
      field_attrs[:constraints][:minLength] = 5
    end

    it 'handles with a valid value' do
      @value = 'string'
      expect(constraints.validate!).to eq(true)
    end

    it 'handles when the value is equal' do
      field_attrs[:constraints][:minLength] = 6
      @value = 'string'
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      field_attrs[:constraints][:minLength] = 10
      @value = 'string'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a minimum length of 10')
    end

  end

  context 'with array type' do

    before(:each) do
      field_attrs[:type] = 'array'
      field_attrs[:constraints][:minLength] = 2
      @value = ['a', 'b', 'c']
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles when the value is equal' do
      field_attrs[:constraints][:minLength] = 3
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      field_attrs[:constraints][:minLength] = 10
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a minimum length of 10')
    end

  end

  context 'with object type' do

    before(:each) do
      field_attrs[:type] = 'object'
      field_attrs[:constraints][:minLength] = 2
      @value = {a: 1, b: 2, c: 3}
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles when the value is equal' do
      field_attrs[:constraints][:minLength] = 3
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      field_attrs[:constraints][:minLength] = 10
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a minimum length of 10')
    end

  end

  it 'raises for an unsupported type' do
    @value = 2
    field_attrs[:constraints][:minLength] = 3
    field_attrs[:type] = 'integer'
    expect { constraints.validate! }.to raise_error(TableSchema::ConstraintNotSupported, 'The field type `integer` does not support the `minLength` constraint')
  end

end
