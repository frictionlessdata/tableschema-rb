module JsonTableSchema
  class Schema
    include JsonTableSchema::Validate
    include JsonTableSchema::Model

    def initialize(schema)
      @schema = schema
      @messages = []
      load_validator!
    end

  end
end
