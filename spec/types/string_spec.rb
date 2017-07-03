describe TableSchema::Types::String do

  let(:field) {
    TableSchema::Field.new({
      name: 'Name',
      type: 'string',
      format: 'default',
    })
  }

  let(:type) { TableSchema::Types::String.new(field) }

  it 'casts a simple string' do
    value = 'a string'
    expect(type.cast(value)).to eq('a string')
  end

  it 'returns an error if the value is not a string' do
    value = 1
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)
  end

  it 'raises for an unsupported format' do
    field[:format] = 'foo'
    value = 'foo'
    expect { type.cast(value) }.to raise_error(TableSchema::InvalidFormat)
  end

  context 'emails' do

    before(:each) do
      field[:format] = 'email'
    end

    it 'casts an email' do
      value = 'test@test.com'
      expect(type.cast(value)).to eq(value)

      value = '\$A12345@example.com'
      expect(type.cast(value)).to eq(value)

      value = '!def!xyz%abc@example.com'
      expect(type.cast(value)).to eq(value)
    end

    it 'fails with an invalid email' do
      value = 1
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidCast)

      value = 'notanemail'
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidEmail)
    end

  end

  context 'uris' do

    before(:each) do
      field[:format] = 'uri'
    end

    it 'casts a uri' do
      value = 'http://test.com'
      expect(type.cast(value)).to eq(value)
    end

    it 'raises an expection for an invalid URI' do
      value = 'notauri'
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidURI)
    end

  end

  context 'uuid' do

    before(:each) do
      field[:format] = 'uuid'
    end


    it 'casts a uuid' do
      value = '12345678123456781234567812345678'
      expect(type.cast(value)).to eq(value)

      value = 'urn:uuid:12345678-1234-5678-1234-567812345678'
      expect(type.cast(value)).to eq(value)

      value = '123e4567-e89b-12d3-a456-426655440000'
      expect(type.cast(value)).to eq(value)
    end

    it 'raises for invalid uuids' do
      value = '1234567812345678123456781234567?'
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidUUID)

      value = '1234567812345678123456781234567'
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidUUID)

      value = 'X23e4567-e89b-12d3-a456-426655440000'
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidUUID)
    end

  end

  context 'binary' do

    before(:each) do
      field[:format] = 'binary'
    end

    it 'casts a binary string' do
      value = "QmluYXJ5IFN0cmluZw=="
      expect(type.cast(value)).to eq('Binary String')

      value = ''
      expect(type.cast(value)).to eq('')
    end

    it 'raises for invalid binary strings' do
      value = "QmluYXJ5IFN0cmluZw==\n"
      expect { type.cast(value) }.to raise_error(TableSchema::InvalidBinary)
    end

  end

end
