module TableSchema
  class Table

    attr_reader :schema

    def self.infer_schema(csv, opts = {})
      TableSchema::Table.new(csv, nil, opts)
    end

    def initialize(csv, descriptor, opts = {})
      @opts = opts
      @csv = parse_csv(csv)
      @schema = descriptor.nil? ? infer_schema(@csv) : TableSchema::Schema.new(descriptor)
    end

    def parse_csv(csv)
      csv = csv.is_a?(Array) ? StringIO.new(array_to_csv csv) : open(csv)
      CSV.new(csv, csv_options)
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
          Hash[row.map.with_index { |col, i| [headers[i].to_sym, col] }]
        end
      end

      def infer_schema(csv)
        headers = csv.first.to_h.keys
        csv.rewind
        inferer = TableSchema::Infer.new(headers, csv)
        inferer.schema
      end

  end
end
