require 'spec_helper'

describe TableSchema::Constraints::Required do

  let(:field_attrs) {
    {
      name: 'Name',
      format: 'default',
      type: 'string',
      constraints: {}
    }
  }

  let(:field) { TableSchema::Field.new(field_attrs)}

  let(:constraints) { TableSchema::Constraints.new(field, @value) }

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
