module TableSchema
  class Table

    # Public

    attr_reader :headers, :schema

    def initialize(source, schema: nil, csv_options: {})
      @csv_options = csv_options.merge(headers: true)
      @csv = parse_csv(source)
      @descriptor = schema
      @headers = initialize_headers
      if !@descriptor.nil?
        @schema = TableSchema::Schema.new(@descriptor)
        initialize_unique_colums
      end
    end

    def iter(keyed: false, cast: true, limit: nil)
      unless block_given?
        return enum_for(:iter, limit: limit, cast: cast, keyed: keyed)
      end

      @csv.each_with_index do |row, i|
        break if limit && (limit <= i)
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

    def read(keyed: false, cast: true, limit: nil)
      iterator = self.iter(keyed: keyed, cast: cast, limit: limit)
      iterator.to_a
    end

    def infer()
      if !@schema
        inferer = TableSchema::Infer.new(@headers, @csv)
        @schema = inferer.schema
        initialize_unique_colums
        @csv.rewind
      end
      @schema.descriptor
    end

    def save(target)
      CSV.open(target, "wb", @csv_options) do |csv|
        csv << @headers
        self.iter{ |row| csv << row }
      end
      true
    end

    # Private

    private

    def parse_csv(csv)
      csv = csv.is_a?(Array) ? StringIO.new(array_to_csv csv) : open(csv)
      CSV.new(csv, @csv_options)
    end

    def array_to_csv(array)
      array.map { |row| row.to_csv(row_sep: nil) }.join("\r\n")
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
