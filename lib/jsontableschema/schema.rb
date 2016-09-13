module JsonTableSchema
  class Schema
    include JsonTableSchema::Validate

    def initialize(schema)
      @schema = schema
      @messages = []
      load_validator!
    end

  end
end
