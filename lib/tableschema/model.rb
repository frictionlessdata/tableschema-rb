require 'tableschema/defaults'

module TableSchema
  module Model

    def headers
      fields.map { |f| transform(f[:name]) }
    rescue NoMethodError
      []
    end

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

    def get_type(key)
      get_field(key)[:type]
    end

    def get_constraints(key)
      get_field(key)[:constraints] || {}
    end

    def required_headers
      fields.select { |f| f.fetch(:constraints, {}).fetch(:required, nil) == true }
            .map { |f| transform(f[:name]) }
    end

    def unique_headers
      fields.select { |f| f.fetch(:constraints, {}).fetch(:unique, nil) == true }
            .map { |f| transform(f[:name]) }
    end

    def has_field?(key)
      get_field(key) != nil
    end

    def get_field(key)
      fields.find { |f| f[:name] == key }
    end

    def get_fields_by_type(type)
      fields.select { |f| f[:type] == type }
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
