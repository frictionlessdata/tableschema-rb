module TableSchema
  module Data

    attr_reader :errors

    def cast_rows(rows, fail_fast = true, limit = nil)
      @errors ||= []
      parsed_rows = []
      rows.each_with_index do |r, i|
        begin
          break if limit && (limit <= i)
          r = r.fields if r.class == CSV::Row
          parsed_rows << cast_row(r, fail_fast)
        rescue MultipleInvalid, ConversionError => e
          raise e if fail_fast == true
          @errors << e if e.is_a?(ConversionError)
        end
      end
      check_for_errors
      parsed_rows
    end

    alias_method :convert, :cast_rows

    def cast_row(row, fail_fast = true)
      @errors ||= []
      raise_header_error(row) if row.count != fields.count
      fields.each_with_index do |field,i|
        row[i] = cast_column(field, row[i], fail_fast)
      end
      check_for_errors
      row
    end

    alias_method :convert_row, :cast_row

    private

    def raise_header_error(row)
      raise(TableSchema::ConversionError.new("The number of items to convert (#{row.count}) does not match the number of headers in the schema (#{fields.count})"))
    end

    def check_for_errors
      raise(TableSchema::MultipleInvalid.new("There were errors parsing the data")) if @errors.count > 0
    end

    def cast_column(field, col, fail_fast)
      field.cast_value(col)
    rescue Exception => e
      if fail_fast == true
        raise e
      else
        @errors << e
      end
    end

    alias_method :convert_column, :cast_column

  end
end
