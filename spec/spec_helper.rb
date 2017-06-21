require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tableschema'
require 'webmock/rspec'

def load_descriptor(filename)
  body = File.read File.join( File.dirname(__FILE__), "fixtures", filename)
  JSON.parse(body)
end
