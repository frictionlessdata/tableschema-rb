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
      initialize_unique_colums
    end

    def iter(row_limit: nil, cast: true, keyed: false)
      unless block_given?
        return enum_for(:iter, row_limit: row_limit, cast: cast, keyed: keyed)
      end

      @csv.each_with_index do |row, i|
        break if row_limit && (row_limit <= i)
        if cast == true
          cast_values = @schema.cast_row(row)
          row = CSV::Row.new(@headers, cast_values)
          check_unique_fields(row, i)
        end
        if keyed == true
          yield row.to_h
        else
          yield row.fields
        end
        collect_unique_fields(row, i)
      end

      @csv.rewind
    end

    def read(row_limit: nil, cast: true, keyed: false)
      iterator = self.iter(row_limit: row_limit, cast: cast, keyed: keyed)
      iterator.to_a
    end

    def save(target)
      CSV.open(target, "wb", @csv_options) do |csv|
        csv << @headers
        self.iter{ |row| csv << row }
      end
      true
    end

    private

    def parse_csv(csv)
      csv = csv.is_a?(Array) ? StringIO.new(array_to_csv csv) : open(csv)
      CSV.new(csv, @csv_options)
    end

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
        @schema.unique_headers.each{ |header| @unique_columns[header] = [] }
      end
    end

    def collect_unique_fields(row, row_number)
      @unique_columns.each { |col_name, values| values[row_number] = row[col_name] }
    end

    def check_unique_fields(row, row_number)
      @unique_columns.each do |col_name, values|
        row_value = row[col_name]
        previous_values = values[0..row_number-1]
        previous_values.map!{|value| @schema.get_field(col_name).cast_type(value)}
        if previous_values.include?(row_value)
          raise TableSchema::ConstraintError.new("The values for the field `#{col_name}` should be unique but value `#{row_value}` is repeated")
        end
      end
    end

  end
end
