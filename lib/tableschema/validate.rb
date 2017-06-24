module TableSchema
  module Validate

    attr_reader :messages

    def load_validator!
      filepath = File.join(File.dirname(__FILE__), '..', 'profiles', 'table-schema.json')
      @validator ||= JSON.parse(File.read filepath)
    end

    def valid?
      validate
      @messages.count == 0
    end

    def validate
      @messages = JSON::Validator.fully_validate(@validator, self)
      check_primary_keys
      check_foreign_keys
    end

    private

      def check_primary_keys
        return if self['primaryKey'].nil?
        primary_keys.each { |pk| check_field_value(pk, 'primaryKey') }
      end

      def check_foreign_keys
        return if self['foreignKeys'].nil?
        self['foreignKeys'].each do |key|
          foreign_key_fields(key).each { |fk| check_field_value(fk, 'foreignKey.fields') }
          if field_count_mismatch?(key)
            add_error("A JSON Table Schema foreignKey.fields must contain the same number entries as foreignKey.reference.fields.")
          end
        end
      end

      def check_field_value(key, type)
        if headers.select { |f| key == f }.count == 0
          add_error("The JSON Table Schema #{type} value `#{key}` is not found in any of the schema's field names")
        end
      end

      def foreign_key_fields(key)
        [key['fields']].flatten
      end

      def field_count_mismatch?(key)
        key['reference'] && ([key['fields']].flatten.count != [key['reference']['fields']].flatten.count)
      end

      def add_error(error)
        @messages << error
      end

  end
end
