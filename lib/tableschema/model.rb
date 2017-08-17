require 'tableschema/defaults'

module TableSchema
  module Model

    def headers
      fields.map { |f| transform(f[:name]) }
    rescue NoMethodError
      []
    end

    alias :field_names :headers

    def fields
      self[:fields]
    end

    def primary_keys
      [self[:primaryKey]].flatten.reject { |k| k.nil? }
    end

    def foreign_keys
      self[:foreignKeys] || []
    end

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

    def get_field(field_name)
      fields.find { |f| f[:name] == field_name }
    end

    def get_fields_by_type(type)
      fields.select { |f| f[:type] == type }
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
      field
    end

    private

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

  end
end
