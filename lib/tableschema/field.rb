require 'tableschema/defaults'

module TableSchema
  class Field < Hash
    include TableSchema::Helpers

    attr_reader :name, :type, :format, :missing_values, :constraints

    def initialize(descriptor, missing_values=nil)
      self.merge! deep_symbolize_keys(descriptor)
      @name = self[:name]
      @type = self[:type] = self.fetch(:type, TableSchema::DEFAULTS[:type])
      @format = self[:format] = self.fetch(:format, TableSchema::DEFAULTS[:format])
      @constraints = self[:constraints] = self.fetch(:constraints, {})
      @missing_values = missing_values || default_missing_values
    end

    def descriptor
      self.to_h
    end

    def cast_value(col)
      converter = type_class.new(self)
      converter.cast(col)
    end

    def test_value(col)
      converter = type_class.new(self)
      converter.test(col)
    end

    private

      def default_missing_values
        defaults = TableSchema::DEFAULTS[:missing_values]
        self.type == 'string' ? defaults - [''] : defaults
      end

      def type_class
        Object.const_get get_class_for_type(type)
      end

  end
end
