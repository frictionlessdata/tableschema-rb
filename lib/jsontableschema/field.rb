module JsonTableSchema
  class Field < Hash
    include JsonTableSchema::Helpers

    attr_reader :type_class

    def initialize(descriptor)
      self.merge! descriptor
      @type_class = get_type
    end

    def name
      self['name']
    end

    def type
      self['type'] || 'string'
    end

    def format
      self['format'] || 'default'
    end

    def constraints
      self['constraints'] || {}
    end

    def cast_value(value)
      klass = @type_class.send(:new, self)
      klass.cast(value)
    end

    private

      def get_type
        Object.const_get get_class_for_type(type)
      end

  end
end
