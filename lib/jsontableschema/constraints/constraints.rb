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
        result = self.send("check_#{underscore c.first}")
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

  end
end
