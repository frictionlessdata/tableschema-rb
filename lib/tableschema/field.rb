module TableSchema
  class Field < Hash
    include TableSchema::Helpers

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

    def cast_value(col)
      klass = get_class_for_type(type)
      converter = Kernel.const_get(klass).new(self)
      converter.cast(col)
    end

    private

      def get_type
        Object.const_get get_class_for_type(type)
      end

  end
end
