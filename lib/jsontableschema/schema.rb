module JsonTableSchema
  class Schema < Hash
    include JsonTableSchema::Validate
    include JsonTableSchema::Model
    include JsonTableSchema::Data
    include JsonTableSchema::Helpers

    def initialize(descriptor, opts = {})
      self.merge! parse_schema(descriptor)
      @messages = []
      @opts = opts
      load_fields!
      load_validator!
      expand!
    end

    def parse_schema(descriptor)
      if descriptor.class == Hash
        descriptor
      elsif descriptor.class == String
        begin
          JSON.parse open(descriptor).read
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

  end
end
