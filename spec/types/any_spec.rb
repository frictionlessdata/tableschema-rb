describe TableSchema::Types::Any do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'any',
      format: 'default',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Any.new(field) }

  it 'returns the value' do
    ['1', 2, Time.now].each do |value|
      expect(type.cast(value)).to eq(value)
    end
  end

end
