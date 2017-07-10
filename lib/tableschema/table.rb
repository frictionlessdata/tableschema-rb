module TableSchema
  class Table

    attr_reader :schema, :headers

    def self.infer_schema(csv, csv_options: {})
      TableSchema::Table.new(csv, nil, csv_options)
    end

    def initialize(csv, descriptor, csv_options: {})
      @csv_options = csv_options.merge(headers: true)
      @csv = parse_csv(csv)
      @headers = initialize_headers
      @schema = descriptor.nil? ? infer_schema : TableSchema::Schema.new(descriptor)
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
        if cast == true
          begin
            cast_values = @schema.cast_row(row, fail_fast: fail_fast)
            row = CSV::Row.new(@headers, cast_values)
          rescue TableSchema::MultipleInvalid => e
            has_errors = true
          end
        end
        if keyed == true
          yield row.to_h
        else
          yield row.fields
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

  end
end
