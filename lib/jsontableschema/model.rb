module JsonTableSchema
  module Model

    def headers
      fields.map { |f| f['name'] }
    rescue NoMethodError
      []
    end

    def required_headers
      fields.select { |f| f['constraints']['required'] == true }
            .map { |f| f['name'] }
    rescue NoMethodError
      []
    end

    def has_field?(key)
      get_field(key) != nil
    end

    def get_field(key)
      fields.find { |f| f['name'] == key }
    end

    private

      def fields
        @schema['fields']
      end

  end
end
