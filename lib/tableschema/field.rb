require 'tableschema/defaults'

module TableSchema
  class Field < Hash
    include TableSchema::Helpers

    attr_reader :type_class, :missing_values

    def initialize(descriptor, missing_values=TableSchema::DEFAULTS['missing_values'])
      self.merge! descriptor
      @type_class = get_type
      @missing_values = missing_values
    end

    def name
      self['name']
    end

    def type
      self['type'] || TableSchema::DEFAULTS['type']
    end

    def format
      self['format'] || TableSchema::DEFAULTS['format']
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
