require 'spec_helper'

describe TableSchema::Constraints do

  let(:field_attrs) {
    {
      name: 'Name',
      format: 'default',
      constraints: {}
    }
  }

  let(:field) { TableSchema::Field.new(field_attrs)}

  let(:constraints) { TableSchema::Constraints.new(field, @value) }

  describe TableSchema::Constraints::Required do

    before(:each) do
      field_attrs[:type] = 'string'
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
      field_attrs[:constraints][:required] = true
      expect(constraints.validate!).to eq(true)
    end

    it 'handles a required false constraint with no value' do
      @value = ''
      field_attrs[:constraints][:required] = false
      expect(constraints.validate!).to eq(true)
    end
    it 'handles a required false constraint with a value' do
      @value = 'string'
      field_attrs[:constraints][:required] = false
      expect(constraints.validate!).to eq(true)
    end

    it 'raises an error for a required true constraint with no value' do
      @value = ''
      field_attrs[:constraints][:required] = true
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError)
    end

  end

  describe TableSchema::Constraints::MinLength do

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

  describe TableSchema::Constraints::MaxLength do

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

  describe TableSchema::Constraints::Minimum do

    context 'with integer type' do

      before(:each) do
        field_attrs[:type] = 'integer'
        @min = 5
        field_attrs[:constraints][:minimum] = @min
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
        @value = 2
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be less than #{@min}")
      end

    end

    context 'with date type' do

      before(:each) do
        field_attrs[:type] = 'date'
        @min = '1978-05-28'
        field_attrs[:constraints][:minimum] = @min
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
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be less than #{@min}")
      end

    end

    context 'with datetime type' do

      before(:each) do
        field_attrs[:type] = 'datetime'
        @min = '1978-05-28T12:30:20Z'
        field_attrs[:constraints][:minimum] = @min
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
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be less than #{@min}")
      end

    end

    context 'with time type' do

      before(:each) do
        field_attrs[:type] = 'time'
        @min = '11:30:00'
        field_attrs[:constraints][:minimum] = @min
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
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be less than #{@min}")
      end

    end

    context 'with year type' do

      before(:each) do
        field_attrs[:type] = 'year'
        @min = '1986'
        field_attrs[:constraints][:minimum] = @min
      end

      it 'handles with a valid value' do
        @value = 2017
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = 1986
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = 1975
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be less than #{@min}")
      end

    end

    context 'with yearmonth type' do

      before(:each) do
        field_attrs[:type] = 'yearmonth'
        @min = '1986-10'
        field_attrs[:constraints][:minimum] = @min
      end

      it 'handles with a valid value' do
        @value = '1986-11'
        expect(field.test_value(@value)).to eq(true)
      end

      it 'handles with an equal value' do
        @value = [1986, 10]
        expect(field.test_value(@value)).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = '1985-11'
        expect { field.cast_value(@value) }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be less than #{@min}")
      end

    end

    context 'with duration type' do

      before(:each) do
        field_attrs[:type] = 'duration'
        @min = 'P3D'
        field_attrs[:constraints][:minimum] = @min
      end

      it 'handles with a valid value' do
        @value = 'P1Y5M'
        expect(field.test_value(@value)).to eq(true)
      end

      it 'handles with an equal value' do
        @value = 'P3D'
        expect(field.test_value(@value)).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = 'PT15H'
        expect { field.cast_value(@value) }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be less than #{@min}")
      end

    end

    it 'raises for an unsupported type' do
      @value = 'sdsdasdsadsad'
      field_attrs[:constraints][:minimum] = 3
      field_attrs[:type] = 'string'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintNotSupported, 'The field type `string` does not support the `minimum` constraint')
    end

  end

  describe TableSchema::Constraints::Maximum do

    context 'with integer type' do

      before(:each) do
        field_attrs[:type] = 'integer'
        @max = 5
        field_attrs[:constraints][:maximum] = @max
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
        @value = 12
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be more than #{@max}")
      end

    end

    context 'with date type' do

      before(:each) do
        field_attrs[:type] = 'date'
        @max = '1978-05-28'
        field_attrs[:constraints][:maximum] = @max
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
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be more than #{@max}")
      end

    end

    context 'with datetime type' do

      before(:each) do
        field_attrs[:type] = 'datetime'
        @max = '1978-05-28T12:30:20Z'
        field_attrs[:constraints][:maximum] = @max
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
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be more than #{@max}")
      end

    end

    context 'with time type' do

      before(:each) do
        field_attrs[:type] = 'time'
        @max = '11:30:00'
        field_attrs[:constraints][:maximum] = @max
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
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be more than #{@max}")
      end

    end

    context 'with year type' do

      before(:each) do
        field_attrs[:type] = 'year'
        @max = '1986'
        field_attrs[:constraints][:maximum] = @max
      end

      it 'handles with a valid value' do
        @value = 1975
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an equal value' do
        @value = 1986
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = 1998
        expect { constraints.validate! }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be more than #{@max}")
      end

    end

    context 'with yearmonth type' do

      before(:each) do
        field_attrs[:type] = 'yearmonth'
        @max = '1986-10'
        field_attrs[:constraints][:maximum] = @max
      end

      it 'handles with a valid value' do
        @value = '-1986-08'
        expect(field.test_value(@value)).to eq(true)
      end

      it 'handles with an equal value' do
        @value = [1986, 10]
        expect(field.test_value(@value)).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = '2017-11'
        expect { field.cast_value(@value) }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be more than #{@max}")
      end

    end

    context 'with duration type' do

      before(:each) do
        field_attrs[:type] = 'duration'
        @max = 'P3D'
        field_attrs[:constraints][:maximum] = @max
      end

      it 'handles with a valid value' do
        @value = 'PT24H'
        expect(field.test_value(@value)).to eq(true)
      end

      it 'handles with an equal value' do
        @value = 'P3D'
        expect(field.test_value(@value)).to eq(true)
      end

      it 'handles with an invalid value' do
        @value = 'P1Y'
        expect { field.cast_value(@value) }.to raise_error(TableSchema::ConstraintError, "The field `Name` must not be more than #{@max}")
      end

    end

    it 'raises for an unsupported type' do
      @value = 'sdsdasdsadsad'
      field_attrs[:constraints][:maximum] = 3
      field_attrs[:type] = 'string'
      expect { constraints.validate! }.to raise_error(TableSchema::ConstraintNotSupported, 'The field type `string` does not support the `maximum` constraint')
    end

  end

  describe TableSchema::Constraints::Enum do

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

  describe TableSchema::Constraints::Pattern do

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

end
