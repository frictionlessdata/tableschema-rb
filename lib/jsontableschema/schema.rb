module JsonTableSchema
  class Schema < Hash
    include JsonTableSchema::Validate
    include JsonTableSchema::Model

    def initialize(schema, opts = {})
      self.merge! schema
      @messages = []
      @opts = opts
      load_validator!
    end

  end
end
