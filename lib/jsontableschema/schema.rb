module JsonTableSchema
  class Schema < Hash
    include JsonTableSchema::Validate
    include JsonTableSchema::Model

    def initialize(schema, opts = {})
      self.merge! parse_schema(schema)
      @messages = []
      @opts = opts
      load_validator!
    end

    def parse_schema(schema)
      if schema.class == Hash
        schema
      elsif schema.class == String
        JSON.parse open(schema).read
      end
    end

  end
end
