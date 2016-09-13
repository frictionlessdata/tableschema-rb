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

    private

      def check_primary_keys
        return if @schema['primaryKey'].nil?
        primary_keys.each { |pk| check_field_value(pk, 'primaryKey') }
      end

      def check_foreign_keys
        return if @schema['foreignKeys'].nil?
        @schema['foreignKeys'].each do |keys|
          foreign_keys(keys).each { |fk| check_field_value(fk, 'foreignKey.fields') }
          add_error("A JSON Table Schema foreignKey.fields must contain the same number entries as foreignKey.reference.fields.") if field_count_mismatch?(keys)
        end
      end

      def check_field_value(key, type)
        add_error("The JSON Table Schema #{type} value `#{key}` is not found in any of the schema's field names") if field_names.select { |f| key == f }.count == 0
      end

      def primary_keys
        [@schema['primaryKey']].flatten
      end

      def foreign_keys(keys)
        [keys['fields']].flatten
      end

      def field_count_mismatch?(keys)
        keys['reference'] &&([keys['fields']].flatten.count != [keys['reference']['fields']].flatten.count)
      end

      def add_error(error)
        @messages << error
      end

  end
end
