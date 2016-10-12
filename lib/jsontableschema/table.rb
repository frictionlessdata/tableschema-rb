module JsonTableSchema
  class Table

    attr_reader :schema

    def self.infer_schema(csv, opts = {})
      JsonTableSchema::Table.new(csv, nil, opts)
    end

    def initialize(csv, descriptor, opts = {})
      @opts = opts
      @csv = parse_csv(csv)
      @schema = descriptor.nil? ? infer_schema(@csv) : JsonTableSchema::Schema.new(descriptor)
    end

    def parse_csv(csv)
      csv_string = csv.is_a?(Array) ? array_to_csv(csv) : open(csv).read
      CSV.parse(csv_string, csv_options)
    end

    def csv_options
      (@opts[:csv_options] || {}).merge(headers: true)
    end

    def rows(opts = {})
      fail_fast = opts[:fail_fast] || opts[:fail_fast].nil?
      converted = @schema.cast_rows(@csv, fail_fast, opts[:limit])
      opts[:keyed] ? coverted_to_hash(@csv.headers, converted) : converted
    end

    private

      def array_to_csv(array)
        array.map { |row| row.to_csv(row_sep: nil) }.join("\r\n")
      end

      def coverted_to_hash(headers, array)
        array.map do |row|
          Hash[row.map.with_index { |col, i| [headers[i], col] }]
        end
      end

      def infer_schema(csv)
        inferer = JsonTableSchema::Infer.new(csv.headers, csv.to_a)
        inferer.schema
      end

  end
end
