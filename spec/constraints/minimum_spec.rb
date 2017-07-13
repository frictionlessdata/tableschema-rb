require 'spec_helper'

describe TableSchema::Constraints::Minimum do

  let(:field_attrs) {
    {
      name: 'Name',
      format: 'default',
      constraints: {}
    }
  }

  let(:field) { TableSchema::Field.new(field_attrs)}

  let(:constraints) { TableSchema::Constraints.new(field, @value) }

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
