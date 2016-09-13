$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jsontableschema'
require 'webmock/rspec'

def load_schema(schema)
  body = File.read File.join( File.dirname(__FILE__), "fixtures", schema)
  JSON.parse(body)
end
