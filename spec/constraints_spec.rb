require 'spec_helper'

describe TableSchema::Constraints do

  let(:field) {
    {
      'name' => 'Name',
      'type' => '',
      'format' => 'default',
      'constraints' => {}
    }
  }

  let(:constraints) { TableSchema::Constraints.new(field, @value) }

  describe TableSchema::Constraints::Required do

    before(:each) do
      field['type'] = 'string'
    end

    it 'handles an empty constraints hash' do
      @value = 'string'
      expect(constraints.validate!).to eq(true)
    end

    it 'handles an empty constraints hash with no value' do
      @value = ''
      expect(constraints.validate!).to eq(true)
    end

    it 'handles a required true constraint with a value' do
      @value = 'string'
      field['constraints']['required'] = true
      expect(constraints.validate!).to eq(true)
    end

    it 'handles a required false constraint with no value' do
      @value = ''
      field['constraints']['required'] = false
      expect(constraints.validate!).to eq(true)
    end
    it 'handles a required false constraint with a value' do
      @value = 'string'
      field['constraints']['required'] = false
      expect(constraints.validate!).to eq(true)
    end

    it 'raises an error for a required true constraint with no value' do
      @value = ''
      field['constraints']['required'] = true
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError)
    end

  end

  describe TableSchema::Constraints::MinLength do

    context 'with string type' do

      before(:each) do
        field['type'] = 'string'
        field['constraints']['minLength'] = 5
      end

      it 'handles with a valid value' do
        @value = 'string'
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['minLength'] = 6
        @value = 'string'
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['minLength'] = 10
        @value = 'string'
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a minimum length of 10')
      end

    end

    context 'with array type' do

      before(:each) do
        field['type'] = 'array'
        field['constraints']['minLength'] = 2
        @value = ['a', 'b', 'c']
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['minLength'] = 3
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['minLength'] = 10
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a minimum length of 10')
      end

    end

    context 'with object type' do

      before(:each) do
        field['type'] = 'object'
        field['constraints']['minLength'] = 2
        @value = {'a' => 1, 'b' => 2, 'c' => 3}
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['minLength'] = 3
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['minLength'] = 10
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a minimum length of 10')
      end

    end

    it 'raises for an unsupported type' do
      @value = 2
      field['constraints']['minLength'] = 3
      field['type'] = 'integer'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintNotSupported, 'The field type `integer` does not support the `minLength` constraint')
    end

  end

  describe TableSchema::Constraints::MaxLength do

    context 'with string type' do

      before(:each) do
        field['type'] = 'string'
        field['constraints']['maxLength'] = 7
      end

      it 'handles with a valid value' do
        @value = 'string'
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['maxLength'] = 6
        @value = 'string'
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['maxLength'] = 10
        @value = 'stringggggggggggg'
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a maximum length of 10')
      end

    end

    context 'with array type' do

      before(:each) do
        field['type'] = 'array'
        field['constraints']['maxLength'] = 4
        @value = ['a', 'b', 'c']
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['maxLength'] = 3
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['maxLength'] = 2
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a maximum length of 2')
      end

    end

    context 'with object type' do

      before(:each) do
        field['type'] = 'object'
        field['constraints']['maxLength'] = 4
        @value = {'a' => 1, 'b' => 2, 'c' => 3}
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['maxLength'] = 3
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['maxLength'] = 2
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must have a maximum length of 2')
      end

    end

    it 'raises for an unsupported type' do
      @value = 2
      field['constraints']['maxLength'] = 3
      field['type'] = 'integer'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintNotSupported, 'The field type `integer` does not support the `maxLength` constraint')
    end

  end

  describe TableSchema::Constraints::Minimum do

    context 'with integer type' do

      before(:each) do
        field['type'] = 'integer'
        field['constraints']['minimum'] = 5
        @value = 20
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = 5
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['minimum'] = 25
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must not be less than 25')
      end

    end

    context 'with date type' do

      before(:each) do
        field['type'] = 'date'
        field['constraints']['minimum'] = '1978-05-28'
        @value = Date.parse('1978-05-29')
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = Date.parse('1978-05-28')
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = Date.parse('1970-05-28')
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must not be less than 1978-05-28')
      end

    end

    context 'with datetime type' do

      before(:each) do
        field['type'] = 'date'
        field['constraints']['minimum'] = '1978-05-28T12:30:20Z'
        @value = DateTime.parse('1978-05-29T12:30:20Z')
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = DateTime.parse('1978-05-28T12:30:20Z')
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = DateTime.parse('1970-05-29T12:30:20Z')
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must not be less than 1978-05-28T12:30:20Z')
      end

    end

    context 'with time type' do

      before(:each) do
        field['type'] = 'time'
        field['constraints']['minimum'] = '11:30:00'
        @value = Tod::TimeOfDay.parse('12:30:20')
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = Tod::TimeOfDay.parse('11:30:00')
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = Tod::TimeOfDay.parse('07:00:00')
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must not be less than 11:30:00')
      end

    end

    it 'raises for an unsupported type' do
      @value = 'sdsdasdsadsad'
      field['constraints']['minimum'] = 3
      field['type'] = 'string'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintNotSupported, 'The field type `string` does not support the `minimum` constraint')
    end

  end

  describe TableSchema::Constraints::Maximum do

    context 'with integer type' do

      before(:each) do
        field['type'] = 'integer'
        field['constraints']['maximum'] = 5
        @value = 4
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = 5
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['maximum'] = 2
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must not be more than 2')
      end

    end

    context 'with date type' do

      before(:each) do
        field['type'] = 'date'
        field['constraints']['maximum'] = '1978-05-28'
        @value = Date.parse('1978-05-27')
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = Date.parse('1978-05-27')
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = Date.parse('2016-05-28')
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must not be more than 1978-05-28')
      end

    end

    context 'with datetime type' do

      before(:each) do
        field['type'] = 'date'
        field['constraints']['maximum'] = '1978-05-28T12:30:20Z'
        @value = DateTime.parse('1978-05-27T12:30:20Z')
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = DateTime.parse('1978-05-28T12:30:20Z')
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = DateTime.parse('2016-05-29T12:30:20Z')
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must not be more than 1978-05-28T12:30:20Z')
      end

    end

    context 'with time type' do

      before(:each) do
        field['type'] = 'time'
        field['constraints']['maximum'] = '11:30:00'
        @value = Tod::TimeOfDay.parse('10:30:20')
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = Tod::TimeOfDay.parse('11:30:00')
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = Tod::TimeOfDay.parse('14:00:00')
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The field `Name` must not be more than 11:30:00')
      end

    end

    it 'raises for an unsupported type' do
      @value = 'sdsdasdsadsad'
      field['constraints']['maximum'] = 3
      field['type'] = 'string'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintNotSupported, 'The field type `string` does not support the `maximum` constraint')
    end

  end

  describe TableSchema::Constraints::Enum do

    context 'with string type' do

      before(:each) do
        field['type'] = 'string'
        field['constraints']['enum'] = ['alice', 'bob', 'chuck']
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
        field['type'] = 'integer'
        field['constraints']['enum'] = [1,2,3]
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
        field['type'] = 'number'
        field['constraints']['enum'] = ["1.0","2.0","3.0"]
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
        field['type'] = 'boolean'
        field['constraints']['enum'] = [true]
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
        field['constraints']['enum'] = ['yes', 'y', 't', '1', 1]
        expect(constraints.validate!).to eq(true)
      end

    end

    context 'with array type' do

      before(:each) do
        field['type'] = 'array'
        field['constraints']['enum'] = [
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
        field['type'] = 'object'
        field['constraints']['enum'] =  [{'a' => 'first',
                                          'b' => 'second',
                                          'c' => 'third'}]
        @value = {'a' => 'first', 'b' => 'second', 'c' => 'third'}
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = {
            'a' => 'fred',
            'b' => 'alice',
            'c' => 'bob'
          }
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must be in the enum array')
      end

      it 'handles with a valid value and a different order' do
        @value = {'b' => 'second', 'a' => 'first', 'c' => 'third'}
        expect(constraints.validate!).to eq(true)
      end

    end

    context 'with date type' do

      before(:each) do
        field['type'] = 'date'
        field['constraints']['enum'] = ['2015-10-22']
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

  end

  describe TableSchema::Constraints::Pattern do

    context 'with string type' do

        before(:each) do
          field['type'] = 'string'
          field['constraints']['pattern'] = '[0-9]{3}-[0-9]{2}-[0-9]{4}'
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
          field['type'] = 'integer'
          field['constraints']['pattern'] = '[7-9]{3}'
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
          field['type'] = 'number'
          field['constraints']['pattern'] = '7.[0-9]{3}'
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
          field['type'] = 'array'
          field['constraints']['pattern'] = '\[("[a-c]",?\s?)*\]'
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
          field['type'] = 'object'
          field['constraints']['pattern'] = '\{("[a-z]":[0-9],?\s?)*\}'
          @value = {'a' => 1, 'b' => 2, 'c' => 3}
        end

        it 'handles with a valid value' do
          expect(constraints.validate!).to eq(true)
        end

        it 'handles with an invalid value' do
          @value = {'a' => 'fred', 'b' => 2, 'c' => 3}
          expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, 'The value for the field `Name` must match the pattern')
        end

    end

    context 'with date type' do

        before(:each) do
          field['type'] = 'date'
          field['constraints']['pattern'] = '2015-[0-9]{2}-[0-9]{2}'
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

  end

end
