require "jsontableschema/constraints/required"
require "jsontableschema/constraints/min_length"
require "jsontableschema/constraints/max_length"
require "jsontableschema/constraints/minimum"
require "jsontableschema/constraints/maximum"
require "jsontableschema/constraints/enum"
require "jsontableschema/constraints/pattern"

module JsonTableSchema
  class Constraints
    include JsonTableSchema::Helpers

    include JsonTableSchema::Constraints::Required
    include JsonTableSchema::Constraints::MinLength
    include JsonTableSchema::Constraints::MaxLength
    include JsonTableSchema::Constraints::Minimum
    include JsonTableSchema::Constraints::Maximum
    include JsonTableSchema::Constraints::Enum
    include JsonTableSchema::Constraints::Pattern

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
      klass = get_class_for_type(@field['type'])
      Kernel.const_get(klass).supported_constraints.include?(constraint)
    end

    def parse_constraint(constraint)
      if @value.is_a?(::Integer) && constraint.is_a?(::String)
        constraint.to_i
      elsif @value.is_a?(::Tod::TimeOfDay)
        Tod::TimeOfDay.parse(constraint)
      elsif @value.is_a?(::DateTime)
        DateTime.parse(constraint)
      elsif @value.is_a?(::Date) && constraint.is_a?(::String)
        Date.parse(constraint)
      elsif @value.is_a?(::Float) && constraint.is_a?(Array)
        constraint.map { |c| Float(c) }
      elsif @value.is_a?(Boolean) && constraint.is_a?(Array)
        constraint.map { |c| cast_boolean(c) }
      elsif @value.is_a?(Date) && constraint.is_a?(Array)
        constraint.map { |c| Date.parse(c) }
      else
        constraint
      end
    end

  end
end
