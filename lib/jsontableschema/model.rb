module JsonTableSchema
  module Model

    DEFAULTS = {
      'format' => 'default',
      'type' => 'string'
    }

    def headers
      fields.map { |f| transform(f['name']) }
    rescue NoMethodError
      []
    end

    def fields
      self['fields']
    end

    def primary_keys
      [self['primaryKey']].flatten.reject { |k| k.nil? }
    end

    def foreign_keys
      self['foreignKeys'] || []
    end

    def get_type(key)
      get_field(key)['type']
    end

    def get_constraints(key)
      get_field(key)['constraints'] || {}
    end

    def required_headers
      fields.select { |f| f['constraints']!= nil && f['constraints']['required'] == true }
            .map { |f| transform(f['name']) }
    rescue NoMethodError
      []
    end

    def has_field?(key)
      get_field(key) != nil
    end

    def get_field(key)
      fields.find { |f| f['name'] == key }
    end

    def get_fields_by_type(type)
      fields.select { |f| f['type'] == type }
    end

    private

      def fields
        self['fields']
      end

      def transform(name)
        name.downcase! if @opts[:case_insensitive_headers]
        name
      end

      def expand!
        (self['fields'] || []).each do |f|
          f['type'] = DEFAULTS['type'] if f['type'] == nil
          f['format'] = DEFAULTS['format'] if f['format'] == nil
        end
      end

  end
end
