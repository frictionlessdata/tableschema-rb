require 'tableschema/defaults'

module TableSchema
  class Schema < Hash
    include TableSchema::Helpers

    # Public

    attr_reader :errors

    def initialize(descriptor, strict: false, case_insensitive_headers: false)
      self.merge! deep_symbolize_keys(parse_schema(descriptor))
      @case_insensitive_headers = case_insensitive_headers
      @strict = strict
      load_fields!
      load_validator!
      expand!
      @strict == true ? validate! : validate
      self
    end

    def validate
      @errors = Set.new(JSON::Validator.fully_validate(@profile, self))
      check_primary_key
      check_foreign_keys
      @errors.empty?
    end

    def validate!
      validate
      raise SchemaException.new(@errors.first) unless @errors.empty?
      true
    end

    def descriptor
      self.to_h
    end

    def primary_key
      [self[:primaryKey]].flatten.reject { |k| k.nil? }
    end

    def foreign_keys
      self[:foreignKeys] || []
    end

    def fields
      self[:fields]
    end

    def field_names
      fields.map { |f| transform(f[:name]) }
    rescue NoMethodError
      []
    end

    def get_field(field_name)
      fields.find { |f| f[:name] == field_name }
    end

    def add_field(descriptor)
      self[:fields].push(descriptor)
      validate!
      descriptor
    rescue TableSchema::SchemaException => e
      self[:fields].pop
      raise e if @strict
      nil
    end

    def remove_field(field_name)
      field = get_field(field_name)
      self[:fields].reject!{ |f| f.name == field_name }
      validate
      field
    end

    def cast_row(row, fail_fast: true)
      errors = Set.new
      handle_error = lambda { |e| fail_fast == true ? raise(e) : errors << e }
      row = row.fields if row.class == CSV::Row
      if row.count != self.fields.count
        handle_error.call(TableSchema::ConversionError.new("The number of items to convert (#{row.count}) does not match the number of headers in the schema (#{self.fields.count})"))
      end

      self.fields.each_with_index do |field, i|
        begin
          row[i] = field.cast_value(row[i])
        rescue TableSchema::Exception => e
          handle_error.call(e)
        end
      end

      unless errors.empty?
        raise(TableSchema::MultipleInvalid.new("There were errors parsing the data", errors))
      end
      row
    end

    def save(target)
      File.open(target, "w") { |file| file << JSON.pretty_generate(self.descriptor) }
      true
    end

    # Deprecated

    alias :headers :field_names

    def missing_values
      self.fetch(:missingValues, TableSchema::DEFAULTS[:missing_values])
    end

    def get_type(field_name)
      get_field(field_name)[:type]
    end

    def get_constraints(field_name)
      get_field(field_name)[:constraints] || {}
    end

    def required_headers
      fields.select { |f| f.fetch(:constraints, {}).fetch(:required, nil).to_s == 'true' }
            .map { |f| transform(f[:name]) }
    end

    def unique_headers
      fields.select { |f| f.fetch(:constraints, {}).fetch(:unique, nil).to_s == 'true' }
            .map { |f| transform(f[:name]) }
    end

    def has_field?(field_name)
      get_field(field_name) != nil
    end

    def get_fields_by_type(type)
      fields.select { |f| f[:type] == type }
    end

    # Private

    private

    def parse_schema(descriptor)
      if descriptor.class == Hash
        descriptor
      elsif descriptor.class == String
        begin
          JSON.parse(open(descriptor).read, symbolize_names: true)
        rescue Errno::ENOENT
          raise SchemaException.new("File not found at `#{descriptor}`")
        rescue OpenURI::HTTPError => e
          raise SchemaException.new("URL `#{descriptor}` returned #{e.message}")
        rescue JSON::ParserError
          raise SchemaException.new("File at `#{descriptor}` is not valid JSON")
        end
      else
        raise SchemaException.new("A schema must be a hash, path or URL")
      end
    end

    def transform(name)
      name.downcase! if @case_insensitive_headers == true
      name
    end

    def expand!
      (self[:fields] || []).each do |f|
        f[:type] = TableSchema::DEFAULTS[:type] if f[:type] == nil
        f[:format] = TableSchema::DEFAULTS[:format] if f[:format] == nil
      end
    end

    def load_fields!
      self[:fields] = (self[:fields] || []).map { |f| TableSchema::Field.new(f, missing_values) }
    end

    def load_validator!
      filepath = File.join(File.dirname(__FILE__), '..', 'profiles', 'table-schema.json')
      @profile ||= JSON.parse(File.read(filepath), symbolize_names: true)
    end

    def check_primary_key
      return if self[:primaryKey].nil?
      primary_key.each { |pk| check_field_value(pk, 'primaryKey') }
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
