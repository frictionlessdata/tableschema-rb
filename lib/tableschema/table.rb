module TableSchema
  class Table

    attr_reader :schema, :headers, :errors

    def self.infer_schema(csv, csv_options: {})
      TableSchema::Table.new(csv, nil, csv_options)
    end

    def initialize(csv, descriptor, csv_options: {})
      @csv_options = csv_options.merge(headers: true)
      @csv = parse_csv(csv)
      @headers = initialize_headers
      @errors = Set.new()
      @schema = descriptor.nil? ? infer_schema : TableSchema::Schema.new(descriptor)
      initialize_unique_colums
    end

    def parse_csv(csv)
      csv = csv.is_a?(Array) ? StringIO.new(array_to_csv csv) : open(csv)
      CSV.new(csv, @csv_options)
    end

    def iter(row_limit: nil, cast: true, keyed: false, fail_fast: true)
      has_errors = false
      unless block_given?
        return enum_for(:iter, row_limit: row_limit, cast: cast, keyed: keyed, fail_fast: fail_fast)
      end

      @csv.each_with_index do |row, i|
        break if row_limit && (row_limit <= i)
        begin
          if cast == true
            cast_values = cast_row(row, fail_fast: fail_fast, row_number: i)
            row = CSV::Row.new(@headers, cast_values)
          end
          if keyed == true
            yield row.to_h
          else
            yield row.fields
          end
          collect_unique_fields(row)
        rescue TableSchema::Exception => e
          raise e if fail_fast == true
          has_errors = true
          next
        end
      end

      @csv.rewind
      if has_errors == true
        raise(TableSchema::MultipleInvalid.new("There were errors parsing the data", self.schema.errors))
      end
    end

    def read(row_limit: nil, cast: true, keyed: false, fail_fast: true)
      iterator = self.iter(row_limit: row_limit, cast: cast, keyed: keyed, fail_fast: fail_fast)
      iterator.to_a
    end

    def cast_row(row, fail_fast: true, row_number: 0)
      errors = []
      handle_error = lambda { |e| fail_fast == true ? raise(e) : errors.append(e) }
      row = row.fields if row.class == CSV::Row
      if row.count != @schema.fields.count
        handle_error.call(TableSchema::ConversionError.new("The number of items to convert (#{row.count}) does not match the number of headers in the schema (#{@schema.fields.count})"))
      end

      @schema.fields.each_with_index do |field, i|
        begin
          if @unique_columns.keys.include?(field[:name])
            previous_values = @unique_columns[field[:name]][0..row_number-1]
            row[i] = field.cast_value(row[i], previous_values: previous_values)
          else
            row[i] = field.cast_value(row[i])
          end
        rescue TableSchema::Exception => e
          handle_error.call(e)
        end
      end

      unless errors.empty?
        @errors.merge(errors)
        raise(TableSchema::MultipleInvalid.new("There were errors parsing the data", errors))
      end
      row
    end

    private

      def array_to_csv(array)
        array.map { |row| row.to_csv(row_sep: nil) }.join("\r\n")
      end

      def infer_schema
        inferer = TableSchema::Infer.new(@headers, @csv)
        @csv.rewind
        inferer.schema
      end

      def initialize_headers
        headers = @csv.first.to_h.keys
        @csv.rewind
        headers
      end

      def initialize_unique_colums
        @unique_columns = {}
        unless @schema.unique_headers.empty?
          @schema.unique_headers.each{ |header| @unique_columns[header] = []}
        end
      end

      def collect_unique_fields(row)
        unless @unique_columns.empty?
          @schema.unique_headers.each { |h| @unique_columns[h] << row[h] }
        end
      end

  end
end
