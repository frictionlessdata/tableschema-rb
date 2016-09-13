module JsonTableSchema
  class Schema
    include JsonTableSchema::Validate

    def initialize(schema)
      @schema = schema
      @messages = []
    end

  end
end
