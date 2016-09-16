module JsonTableSchema
  module Types
    class Base
      include JsonTableSchema::Helpers


      def initialize(field)
        @field = field
        @constraints = field['constraints'] || {}
        @required = ['true', true].include?(@constraints['required'])
        @type = @field['type']
        set_format
      end

      def cast(value)
        check_required(value)
        return nil if is_null?(value)
        send("cast_#{@format}", value)
      rescue NoMethodError => e
        if e.message.start_with?('undefined method `cast_')
          raise(JsonTableSchema::InvalidFormat.new("The format `#{@format}` is not supported by the type `#{@type}`"))
        else
          raise e
        end
      end

      def set_format
        if @field['format'].start_with?('fmt:')
          @format, @format_string = *@field['format'].split(':', 2)
        else
          @format = @field['format'] || 'default'
        end
      end

      private

        def is_null?(value)
          null_values.include?(value) && @required == false
        end

        def null_values
          ['null', 'none', 'nil', 'nan', '-', '']
        end

        def check_required(value)
          if null_values.include?(value) && @required == true && @type != 'null'
            raise JsonTableSchema::ConstraintError.new("The field #{@field['name']} requires a value")
          end
        end

    end
  end
end
