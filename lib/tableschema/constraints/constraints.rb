require "tableschema/constraints/required"
require "tableschema/constraints/min_length"
require "tableschema/constraints/max_length"
require "tableschema/constraints/minimum"
require "tableschema/constraints/maximum"
require "tableschema/constraints/enum"
require "tableschema/constraints/pattern"

module TableSchema
  class Constraints
    include TableSchema::Helpers

    include TableSchema::Constraints::Required
    include TableSchema::Constraints::MinLength
    include TableSchema::Constraints::MaxLength
    include TableSchema::Constraints::Minimum
    include TableSchema::Constraints::Maximum
    include TableSchema::Constraints::Enum
    include TableSchema::Constraints::Pattern

    def initialize(field, value)
      @field = field
      @value = value
      @constraints = ordered_constraints
    end

    def validate!
      result = true
      @constraints.each do |c|
        constraint = c.first
        if is_supported_type?(constraint)
          result = self.send("check_#{underscore constraint}")
        else
          raise(TableSchema::ConstraintNotSupported.new("The field type `#{@field['type']}` does not support the `#{constraint}` constraint"))
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

    def ordered_constraints
      constraints = @field.fetch('constraints', {})
      ordered_constraints = constraints.select{ |k,v| k == 'required'}
      ordered_constraints.merge!(constraints)
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
        constraint.map { |c| convert_to_boolean(c) }
      elsif @value.is_a?(Date) && constraint.is_a?(Array)
        constraint.map { |c| Date.parse(c) }
      else
        constraint
      end
    end

  end
end
