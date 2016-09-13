module JsonTableSchema
  class Schema
    include JsonTableSchema::Validate

    def initialize(schema)
      @schema = schema
      @messages = []
      load_validator!
    end

    def field_names
      @schema['fields'].map { |f| f['name'] }
    rescue NoMethodError
      []
    end

  end
end
