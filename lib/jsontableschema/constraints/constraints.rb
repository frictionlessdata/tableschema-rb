require "jsontableschema/constraints/required"

module JsonTableSchema
  class Constraints
    include JsonTableSchema::Constraints::Required

    def initialize(field, value)
      @field = field
      @value = value
      @constraints = @field['constraints'] || {}
    end

    def validate!
      result = true
      @constraints.each do |c|
        result = self.send("check_#{c.first}")
      end
      result
    end

    def included
      self.class.ancestors.select { |a| a.to_s.match /Constraints/ } - [self.class]
    end

  end
end
