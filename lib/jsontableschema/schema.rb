module JsonTableSchema
  class Schema
    include JsonTableSchema::Validate
    include JsonTableSchema::Model

    def initialize(schema, opts = {})
      @schema = schema
      @messages = []
      @opts = opts
      load_validator!
    end

  end
end
