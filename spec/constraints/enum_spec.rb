require 'spec_helper'

describe TableSchema::Constraints::Enum do

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
      field_attrs[:constraints][:enum] = ['alice', 'bob', 'chuck']
      @value = 'bob'
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = 'ian'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

    it 'is case sensitive' do
      @value = 'Bob'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

  end

  context 'with integer type' do

    before(:each) do
      field_attrs[:type] = 'integer'
      field_attrs[:constraints][:enum] = [1,2,3]
      @value = 2
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = '6'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

  end

  context 'with number type' do

    before(:each) do
      field_attrs[:type] = 'number'
      field_attrs[:constraints][:enum] = ["1.0","2.0","3.0"]
      @value = Float(3)
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = Float(6)
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

  end

  context 'with boolean type' do

    before(:each) do
      field_attrs[:type] = 'boolean'
      field_attrs[:constraints][:enum] = [true]
      @value = true
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = false
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

    it 'handles when value is equivalent to possible values in enum array' do
      field_attrs[:constraints][:enum] = ['yes', 'y', 't', '1', 1]
      expect(constraints.validate!).to eq(true)
    end

  end

  context 'with array type' do

    before(:each) do
      field_attrs[:type] = 'array'
      field_attrs[:constraints][:enum] = [
        ['first','second','third'],
        ['fred','alice','bob']
      ]
      @value = ['first', 'second', 'third']
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = ['foo', 'bar', 'baz']
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

    it 'handles with a valid value and a different order' do
      @value = ['third', 'second', 'first']
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

  end

  context 'with object type' do

    before(:each) do
      field_attrs[:type] = 'object'
      field_attrs[:constraints][:enum] =  [{a: 'first',
                                        b: 'second',
                                        c: 'third'}]
      @value = {a: 'first', b: 'second', c: 'third'}
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = {
          a: 'fred',
          b: 'alice',
          c: 'bob'
        }
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

    it 'handles with a valid value and a different order' do
      @value = {b: 'second', a: 'first', c: 'third'}
      expect(constraints.validate!).to eq(true)
    end

  end

  context 'with date type' do

    before(:each) do
      field_attrs[:type] = 'date'
      field_attrs[:constraints][:enum] = ['2015-10-22']
      @value = Date.parse('2015-10-22')
    end

    it 'handles with a valid value' do
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = Date.parse('2016-10-22')
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

  end

  context 'with year type' do

    before(:each) do
      field_attrs[:type] = 'year'
      field_attrs[:constraints][:enum] = ['2015', 2018]
    end

    it 'handles with a valid value' do
      @value = 2015
      expect(constraints.validate!).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = 2019
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

  end

  context 'with yearmonth type' do

    before(:each) do
      field_attrs[:type] = 'yearmonth'
      field_attrs[:constraints][:enum] = ['2015-03', [2018, 11]]
    end

    it 'handles with a valid value' do
      @value = '2015-03'
      expect(field.test_value(@value)).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = [2018, 12]
      expect{ field.cast_value(@value) }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

  end

  context 'with duration type' do

    before(:each) do
      field_attrs[:type] = 'duration'
      field_attrs[:constraints][:enum] = ['P3DT6H']
    end

    it 'handles with a valid value' do
      @value = 'P3DT6H'
      expect(field.test_value(@value)).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = 'P3DT8H'
      expect { field.cast_value(@value) }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
    end

  end

end
