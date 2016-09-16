module JsonTableSchema
  module Data

    attr_reader :errors

    def convert_row(row, fail_fast = true)
      @errors ||= []
      raise_header_error(row) if row.count != fields.count
      fields.each_with_index do |field,i|
        row[i] = convert_column(row[i], field, fail_fast)
      end
      if @errors.count > 0
        raise(JsonTableSchema::MultipleInvalid.new("There were errors parsing the row"))
      else
        row
      end
    end

    def raise_header_error(row)
      raise(JsonTableSchema::ConversionError.new("The number of items to convert (#{row.count}) does not match the number of headers in the schema (#{fields.count})"))
    end

    def convert_column(col, field, fail_fast)
      klass = get_class_for_type(field['type'] || 'string')
      converter = Kernel.const_get(klass).new(field)
      converter.cast(col)
    rescue Exception => e
      if fail_fast == true
        raise e
      else
        @errors << e
      end
    end

  end
end
