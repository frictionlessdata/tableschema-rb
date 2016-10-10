module JsonTableSchema
  class Schema < Hash
    include JsonTableSchema::Validate
    include JsonTableSchema::Model
    include JsonTableSchema::Data
    include JsonTableSchema::Helpers

    def initialize(schema, opts = {})
      self.merge! parse_schema(schema)
      @messages = []
      @opts = opts
      load_fields!
      load_validator!
      expand!
    end

    def parse_schema(schema)
      if schema.class == Hash
        schema
      elsif schema.class == String
        begin
          JSON.parse open(schema).read
        rescue Errno::ENOENT
          raise SchemaException.new("File not found at `#{schema}`")
        rescue OpenURI::HTTPError => e
          raise SchemaException.new("URL `#{schema}` returned #{e.message}")
        rescue JSON::ParserError
          raise SchemaException.new("File at `#{schema}` is not valid JSON")
        end
      else
        raise SchemaException.new("A schema must be a hash, path or URL")
      end
    end

  end
end
