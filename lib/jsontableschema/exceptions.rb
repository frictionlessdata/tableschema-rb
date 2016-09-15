module JsonTableSchema
  class SchemaException < Exception
    attr_reader :message

    def initialize message
      @message = message
    end
  end

  class InvalidFormat < Exception ; end
  class InvalidCast < Exception ; end
  class InvalidEmail < Exception ; end
  class InvalidURI < Exception ; end
  class InvalidUUID < Exception ; end
  class InvalidObjectType < Exception ; end
  class InvalidArrayType < Exception ; end
  class InvalidDateType < Exception ; end
  class InvalidTimeType < Exception ; end
  class InvalidDateTimeType < Exception ; end

end
