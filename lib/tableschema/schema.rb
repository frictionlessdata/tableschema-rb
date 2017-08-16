module TableSchema
  class Schema < Hash
    include TableSchema::Validate
    include TableSchema::Model
    include TableSchema::Helpers

    attr_reader :errors

    def initialize(descriptor, case_insensitive_headers: false, strict: false)
      self.merge! deep_symbolize_keys(parse_schema(descriptor))
      @case_insensitive_headers = case_insensitive_headers
      @strict = strict
      load_fields!
      load_validator!
      expand!
      @strict == true ? validate! : validate
      self
    end

    def descriptor
      self.to_h
    end

    def parse_schema(descriptor)
      if descriptor.class == Hash
        descriptor
      elsif descriptor.class == String
        begin
          JSON.parse(open(descriptor).read, symbolize_names: true)
        rescue Errno::ENOENT
          raise SchemaException.new("File not found at `#{descriptor}`")
        rescue OpenURI::HTTPError => e
          raise SchemaException.new("URL `#{descriptor}` returned #{e.message}")
        rescue JSON::ParserError
          raise SchemaException.new("File at `#{descriptor}` is not valid JSON")
        end
      else
        raise SchemaException.new("A schema must be a hash, path or URL")
      end
    end

    def cast_row(row, fail_fast: true)
      errors = []
      handle_error = lambda { |e| fail_fast == true ? raise(e) : errors.append(e) }
      row = row.fields if row.class == CSV::Row
      if row.count != self.fields.count
        handle_error.call(TableSchema::ConversionError.new("The number of items to convert (#{row.count}) does not match the number of headers in the schema (#{self.fields.count})"))
      end

      self.fields.each_with_index do |field, i|
        begin
          row[i] = field.cast_value(row[i])
        rescue TableSchema::Exception => e
          handle_error.call(e)
        end
      end

      unless errors.empty?
        self.errors.merge(errors)
        raise(TableSchema::MultipleInvalid.new("There were errors parsing the data", errors))
      end
      row
    end

    def save(target)
      File.open(target, "w") { |file| file << JSON.pretty_generate(self.descriptor) }
      true
    end

  end
end
