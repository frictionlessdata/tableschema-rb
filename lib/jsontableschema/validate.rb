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
      if @schema.class == Hash
        check_primary_keys
        check_foreign_keys
      end
    end

    def check_primary_keys
      return if @schema['primaryKey'].nil?
      [@schema['primaryKey']].flatten.each do |pk|
        if field_names.select { |f| pk == f }.count == 0
          @messages << "The JSON Table Schema primaryKey value `#{pk}` is not found in any of the schema's field names"
        end
      end
    end

    def check_foreign_keys
      return if @schema['foreignKeys'].nil?
      @schema['foreignKeys'].each do |keys|
        [keys['fields']].flatten.each do |fk|
          if field_names.select { |f| fk == f }.count == 0
            @messages << "The JSON Table Schema foreignKey.fields value `#{fk}` is not found in any of the schema's field names"
          end
        end
        if keys['reference'] &&([keys['fields']].flatten.count != [keys['reference']['fields']].flatten.count)
          @messages << "A JSON Table Schema foreignKey.fields must contain the same number entries as foreignKey.reference.fields."
        end
      end
    end

  end
end
