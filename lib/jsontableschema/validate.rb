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
      check_primary_keys if @schema.class == Hash
    end

    def check_primary_keys
      return if @schema['primaryKey'].nil?
      [@schema['primaryKey']].flatten.each do |pk|
        if @schema['fields'].select { |f| pk == f['name'] }.count == 0
          @messages << "The JSON Table Schema primaryKey value `#{pk}` is not found in any of the schema's field names"
        end
      end
    end

  end
end
