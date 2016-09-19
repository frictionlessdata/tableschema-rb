module JsonTableSchema
  class Infer

    include JsonTableSchema::Helpers

    attr_reader :schema

    def initialize(headers, rows, opts = {})
      @headers = headers
      @rows = rows
      @explicit = opts[:explicit]
      @primary_key = opts[:primary_key]
      @row_limit = opts[:row_limit]

      @schema = {
        'fields' => fields
      }
      @schema['primaryKey'] = @primary_key if @primary_key
      infer!
    end

    def fields
      @headers.map do |header|
        descriptor = {
          'name' => header,
          'title' => '',
          'description' => '',
        }

        constraints = {}
        constraints['required'] = @explicit === true
        constraints['unique'] = (header == @primary_key)
        constraints.delete_if { |k,v| v == false } unless @explicit === true
        descriptor['constraints'] = constraints if constraints.count > 0
        descriptor
      end
    end

    def infer!
      type_matches = []
      @rows.each_with_index do |row, i|
        break if @row_limit && i > @row_limit

        row_length = row.count
        headers_length = @headers.count

        if row_length > headers_length
          row = row[0..headers_length]
        elsif row_length < headers_length
          diff = headers_length - row_length
          fill = [''] * diff
          row = row.push(fill).flatten
        end

        row.each_with_index do |col, i|
          type_matches[i] ||= []
          type_matches[i] << guess_type(col, i)
        end

      end
      resolve_types(type_matches)
      @schema = JsonTableSchema::Schema.new(@schema)
    end

    def guess_type(col, index)
      guessed_type = 'string'
      guessed_format = 'default'

      available_types.reverse_each do |type|
        klass = get_class_for_type(type)
        converter = Kernel.const_get(klass).new(@schema['fields'][index])
        if converter.test(col) === true
          guessed_type = type
          guessed_format = guess_format(converter, col)
          break
        end
      end

      {
        'type' => guessed_type,
        'format' => guessed_format
      }
    end

    def guess_format(converter, col)
      guessed_format = 'default'
      converter.class.instance_methods.grep(/cast_/).each do |method|
        begin
          format = method.to_s
          format.slice!('cast_')
          next if format == 'default'
          converter.send(method, col)
          guessed_format = format
          break
        rescue JsonTableSchema::Exception
        end
      end
      guessed_format
    end

    def resolve_types(results)
      results.each_with_index do |result,v|
        result.uniq!

        if result.count == 1
          rv = result[0]
        else
          counts = {}
          result.each do |r|
            counts[r] ||= 0
            counts[r] += 1
          end

          sorted_counts = counts.sort_by {|_key, value| value}
          rv = sorted_counts[0][0]
        end

        @schema['fields'][v].merge!(rv)
      end

    end

    def available_types
      [
        'any',
        'string',
        'boolean',
        'number',
        'integer',
        'null',
        'date',
        'time',
        'datetime',
        'array',
        'object',
        'geopoint',
        'geojson'
      ]
    end

  end
end
