require 'spec_helper'

describe TableSchema::Field do

  before(:each) do
    @descriptor_min = {name: 'id'}
    @descriptor_min_processed = {
      name: 'id',
      type: 'string',
      format: 'default',
      constraints: {}
    }
    @descriptor_max = {
      name: 'amount',
      type: 'number',
      format: 'default',
      bareNumber: false,
      constraints: {required: true}
    }
  end

  it 'returns the descriptor with defaults' do
    expect(described_class.new(@descriptor_min)).to eq(@descriptor_min_processed)
  end

  it 'returns a name' do
    expect(described_class.new(@descriptor_min).name).to eq('id')
  end

  it 'returns a type' do
    expect(described_class.new(@descriptor_min).type).to eq('string')
    expect(described_class.new(@descriptor_max).type).to eq('number')
  end

  it 'returns a format' do
    expect(described_class.new(@descriptor_min).format).to eq(TableSchema::DEFAULTS[:format])
  end

  it 'returns constraints' do
    expect(described_class.new(@descriptor_min).constraints).to eq({})
    expect(described_class.new(@descriptor_max).constraints).to eq({required: true})
  end

  it 'returns required' do
    expect(described_class.new(@descriptor_min).required).to eq(false)
    expect(described_class.new(@descriptor_max).required).to eq(true)
  end

  it 'returns the correct type class' do
    expect(described_class.new(@descriptor_min).send(:type_class)).to eq(TableSchema::Types::String)
    expect(described_class.new(@descriptor_max).send(:type_class)).to eq(TableSchema::Types::Number)
  end

  it 'cast_value casts valid value' do
    expect(described_class.new(@descriptor_max).cast_value('£10')).to eq(Float(10.0))
  end

  it 'cast_value raises with an incorrect value' do
    expect { described_class.new(@descriptor_max).cast_value('notdecimal') }.to raise_error(
      TableSchema::InvalidCast,
      'notdecimal is not a number'
    )
  end

  it 'test_value returns true for valid value' do
    expect(described_class.new(@descriptor_max).test_value('30.78')).to be true
  end

  it 'test_value returns false for invalid value' do
    expect(described_class.new(@descriptor_min).test_value(100)).to be false
  end
end
