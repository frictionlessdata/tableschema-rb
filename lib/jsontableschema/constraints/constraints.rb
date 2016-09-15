require "jsontableschema/constraints/required"
require "jsontableschema/constraints/min_length"

module JsonTableSchema
  class Constraints
    include JsonTableSchema::Constraints::Required
    include JsonTableSchema::Constraints::MinLength

    def initialize(field, value)
      @field = field
      @value = value
      @constraints = @field['constraints'] || {}
    end

    def validate!
      result = true
      @constraints.each do |c|
        constraint = c.first
        if is_supported_type?(constraint)
          result = self.send("check_#{underscore constraint}")
        else
          raise(JsonTableSchema::ConstraintNotSupported.new("The field type `#{@field['type']}` does not support the `#{constraint}` constraint"))
        end
      end
      result
    end

    private

    def underscore(value)
      value.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
    end

    def is_supported_type?(constraint)
      klass = "JsonTableSchema::Types::#{@field['type'].capitalize}"
      Kernel.const_get(klass).supported_constraints.include?(constraint)
    end

  end
end
