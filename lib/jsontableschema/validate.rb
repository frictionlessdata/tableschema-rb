module JsonTableSchema
  module Validate

    attr_reader :messages

    def load_validator!
      filepath = File.join(File.dirname(__FILE__), '..', '..', 'etc', 'schemas', 'json-table-schema.json')
      @validator ||= JSON.parse(File.read filepath)
    end

    def valid?
      validate
      @messages.count == 0
    end

    def validate
      @messages = JSON::Validator.fully_validate(@validator, @schema)
    end

  end
end
