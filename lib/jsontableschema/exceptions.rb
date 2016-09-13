module JsonTableSchema
  class SchemaException < Exception
    attr_reader :message

    def initialize message
      @message = message
    end
  end
end
