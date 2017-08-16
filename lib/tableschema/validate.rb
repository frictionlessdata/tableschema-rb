module TableSchema
  module Validate

    attr_reader :errors

    def load_validator!
      filepath = File.join(File.dirname(__FILE__), '..', 'profiles', 'table-schema.json')
      @validator ||= JSON.parse(File.read(filepath), symbolize_names: true)
    end

    def validate
      @errors = Set.new(JSON::Validator.fully_validate(@validator, self))
      check_primary_keys
      check_foreign_keys
      @errors.empty?
    end

    def validate!
      validate
      raise SchemaException.new(@errors.first) unless @errors.empty?
      true
    end

    private

    def check_primary_keys
      return if self[:primaryKey].nil?
      primary_keys.each { |pk| check_field_value(pk, 'primaryKey') }
    end

    def check_foreign_keys
      return if self[:foreignKeys].nil?
      self[:foreignKeys].each do |key|
        if field_type_mismatch?(key)
          add_error("A TableSchema `foreignKey.fields` value must be the same type as `foreignKey.reference.fields`")
        end
        if field_count_mismatch?(key)
          add_error("A TableSchema `foreignKey.fields` must contain the same number of entries as `foreignKey.reference.fields`")
        end
        foreign_key_fields(key).each { |fk| check_field_value(fk, 'foreignKey.fields') }
        if key.fetch(:reference).fetch(:resource).empty?
          foreign_key_fields(key.fetch(:reference)).each { |fk| check_field_value(fk, 'foreignKey.reference.fields')}
        end
      end
    end

    def check_field_value(key, type)
      if headers.select { |f| key == f }.count == 0
        add_error("The TableSchema #{type} value `#{key}` is not found in any of the schema's field names")
      end
    end

    def foreign_key_fields(key)
      [key.fetch(:fields)].flatten
    end

    def field_count_mismatch?(key)
      foreign_key_fields(key).count != foreign_key_fields(key.fetch(:reference)).count
    end

    def field_type_mismatch?(key)
      key.fetch(:fields).class.name != key.fetch(:reference).fetch(:fields).class.name
    end

    def add_error(error)
      @errors << error
    end

  end
end
