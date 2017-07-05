describe TableSchema::Types::Duration do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'duration',
      constraints: {
        required: true
      }
    })
  }

  let(:type) { TableSchema::Types::Duration.new(field) }

  it 'correctly parses an ISO8601 duration string' do
    complete_duration = 'P3Y6M4DT12H30M5S'
    short_duration = 'PT3.5H'

    expect(type.cast(complete_duration).to_f).to eq(110839937.0)
    expect(type.cast(short_duration).to_f).to eq(12600.0)
  end

  it 'raises for incorrect duration values' do
    [
      'T2H',
      2,
      1245.7,
    ].each do |value|
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidDurationType)
    end
  end
end
