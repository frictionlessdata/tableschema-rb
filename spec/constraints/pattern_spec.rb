require 'spec_helper'

describe TableSchema::Constraints::Pattern do

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
        field_attrs[:constraints][:pattern] = '[0-9]{3}-[0-9]{2}-[0-9]{4}'
        @value = '078-05-1120'
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = '078-05-112A'
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must match the pattern')
      end

  end

  context 'with integer type' do

      before(:each) do
        field_attrs[:type] = 'integer'
        field_attrs[:constraints][:pattern] = '[7-9]{3}'
        @value = 789
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = 678
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must match the pattern')
      end

  end

  context 'with number type' do

      before(:each) do
        field_attrs[:type] = 'number'
        field_attrs[:constraints][:pattern] = '7.[0-9]{3}'
        @value = 7.123
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = 7.12
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must match the pattern')
      end

  end

  context 'with array type' do

      before(:each) do
        field_attrs[:type] = 'array'
        field_attrs[:constraints][:pattern] = '\[("[a-c]",?\s?)*\]'
        @value = ['a', 'b', 'c']
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = ['a', 'b', 'c', 'd']
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must match the pattern')
      end

  end

  context 'with object type' do

      before(:each) do
        field_attrs[:type] = 'object'
        field_attrs[:constraints][:pattern] = '\{("[a-z]":[0-9],?\s?)*\}'
        @value = {a: 1, b: 2, c: 3}
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = {a: 'fred', b: 2, c: 3}
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must match the pattern')
      end

  end

  context 'with date type' do

      before(:each) do
        field_attrs[:type] = 'date'
        field_attrs[:constraints][:pattern] = '2015-[0-9]{2}-[0-9]{2}'
        @value = '2015-01-23'
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = '2013-01-23'
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must match the pattern')
      end

  end

  context 'with yearmonth type' do

    before(:each) do
      field_attrs[:type] = 'yearmonth'
      field_attrs[:constraints][:pattern] = '201[53]-[0-9]{2}'
    end

    it 'handles with valid value' do
      @value = '2015-01'
      expect(field.test_value(@value)).to eq(true)
    end

    it 'handles with an invalid value' do
      @value = '2016-12'
      expect { field.cast_value(@value) }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must match the pattern')
    end

  end

end
