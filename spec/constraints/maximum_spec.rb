require 'spec_helper'

describe TableSchema::Constraints::Maximum do

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
