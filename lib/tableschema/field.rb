require 'tableschema/defaults'

module TableSchema
  class Field < Hash
    include TableSchema::Helpers

    # Public

    attr_reader :name, :type, :format, :required, :constraints

    def initialize(descriptor, missing_values=nil)
      self.merge! deep_symbolize_keys(descriptor)
      @name = self[:name]
      @type = self[:type] = self.fetch(:type, TableSchema::DEFAULTS[:type])
      @format = self[:format] = self.fetch(:format, TableSchema::DEFAULTS[:format])
      @constraints = self[:constraints] = self.fetch(:constraints, {})
      @required = @constraints.fetch(:required, false)
      @missing_values = missing_values || default_missing_values
    end

    def descriptor
      self.to_h
    end

    def cast_value(value, constraints: true)
      cast_value = cast_type(value)
      return cast_value if constraints == false
      TableSchema::Constraints.new(self, cast_value).validate!
      cast_value
    end

    def test_value(value, constraints: true)
      cast_value(value, constraints: constraints)
      true
    rescue TableSchema::Exception
      false
    end

    def cast_type(value)
      if is_null?(value)
        nil
      else
        type_class.new(self).cast(value)
      end
    end

    # Private

    private

      def default_missing_values
        defaults = TableSchema::DEFAULTS[:missing_values]
        @type == 'string' ? defaults - [''] : defaults
      end

      def type_class
        Object.const_get get_class_for_type(@type)
      end

      def is_null?(value)
        @missing_values.include?(value)
      end

  end
end
