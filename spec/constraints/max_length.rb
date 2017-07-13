require 'spec_helper'

describe TableSchema::Constraints::MaxLength do

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
      field_attrs[:constraints][:maxLength] = 7
    end

    it 'handles with a valid value' do
      @value = 'string'
      expect(constraints.validate!).to eq(true)
    end

    it 'handles when the value is equal' do
      field_attrs[:constraints][:maxLength] = 6
      @value = 'string'
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      field_attrs[:constraints][:maxLength] = 10
      @value = 'stringggggggggggg'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a maximum length of 10')
    end

  end

  context 'with array type' do

    before(:each) do
      field_attrs[:type] = 'array'
      field_attrs[:constraints][:maxLength] = 4
      @value = ['a', 'b', 'c']
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles when the value is equal' do
      field_attrs[:constraints][:maxLength] = 3
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      field_attrs[:constraints][:maxLength] = 2
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a maximum length of 2')
    end

  end

  context 'with object type' do

    before(:each) do
      field_attrs[:type] = 'object'
      field_attrs[:constraints][:maxLength] = 4
      @value = {a: 1, b: 2, c: 3}
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles when the value is equal' do
      field_attrs[:constraints][:maxLength] = 3
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      field_attrs[:constraints][:maxLength] = 2
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a maximum length of 2')
    end

  end

  it 'raises for an unsupported type' do
    @value = 2
    field_attrs[:constraints][:maxLength] = 3
    field_attrs[:type] = 'integer'
    expect { constraints.validate! }.to raise_error(TableSchema::ConstraintNotSupported, 'The field type `integer` does not support the `maxLength` constraint')
  end

end
