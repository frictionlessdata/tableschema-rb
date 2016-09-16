module JsonTableSchema
  class Table

    attr_reader :schema

    def initialize(csv, schema, opts = {})
      @schema = JsonTableSchema::Schema.new(schema)
      @opts = opts
      @csv = parse_csv(csv)
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
      rows = opts[:limit] ? @csv.to_a.drop(1).take(opts[:limit]) : @csv.to_a.drop(1)
      converted = @schema.convert(rows, fail_fast)
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

  end
end
