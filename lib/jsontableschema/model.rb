module JsonTableSchema
  module Model

    def headers
      @schema['fields'].map { |f| f['name'] }
    rescue NoMethodError
      []
    end

  end
end
