[![Build Status](http://img.shields.io/travis/theodi/jsontableschema.rb.svg?style=flat-square)](https://travis-ci.org/theodi/jsontableschema.rb)
[![Dependency Status](http://img.shields.io/gemnasium/theodi/jsontableschema.rb.svg?style=flat-square)](https://gemnasium.com/theodi/jsontableschema.rb)
[![Coverage Status](https://coveralls.io/repos/github/theodi/jsontableschema.rb/badge.svg)](https://coveralls.io/github/theodi/jsontableschema.rb)
[![Code Climate](http://img.shields.io/codeclimate/github/theodi/jsontableschema.rb.svg?style=flat-square)](https://codeclimate.com/github/theodi/jsontableschema.rb)
[![Gem Version](http://img.shields.io/gem/v/jsontableschema.svg?style=flat-square)](https://rubygems.org/gems/jsontableschema)
[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://theodi.mit-license.org)

# JSON Table Schema

A utility library for working with [JSON Table Schema](http://dataprotocols.org/json-table-schema/) in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsontableschema'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jsontableschema

## Usage

### Parse a CSV

Validate and cast data from a CSV as described by a schema.

```ruby
schema = {
    "fields": [
        {
            "name" => "id",
            "title" => "Identifier",
            "type" => "integer"
        },
        {
            "name" => "title",
            "title" => "Title",
            "type" => "string"
        }
    ]
} # Can also be a URL or a path

csv = 'https://raw.githubusercontent.com/okfn/jsontableschema-py/master/data/simple_data.csv' # Can also be a url or array of arrays

table = JsonTableSchema::Table(csv, schema)
table.rows
#=> [[1,'foo'],[2,'bar'],[3,'baz']]
```

### Validate a schema

To validate that a schema meets the JSON Table Schema spec, you can pass a schema to the initializer like so:

```ruby
schema_hash = {
  "fields" => [
      {
          "name" => "id"
      },
      {
          "name" => "height"
      }
  ]
}

schema = JsonTableSchema::Schema.new(schema_hash)
schema.valid?
#=> true
```

You can also pass a file path or URL to the initializer:

```ruby
schema = JsonTableSchema::Schema.new('http://example.org/schema.json')
schema.valid?
#=> true
```

If the schema is invalid, you can access the errors via the `messages` attribute

```ruby
schema_hash = {
  "fields" => [
    {
      "name"=>"id",
      "title"=>"Identifier",
      "type"=>"integer"
   },
   {
     "name"=>"title",
     "title"=>"Title",
     "type"=>"string"
    }
  ],
 "primaryKey"=>"identifier"
}

schema.valid?
#=> false
schema.messages
#=> ["The JSON Table Schema primaryKey value `identifier` is not found in any of the schema's field names"]
```

## Schema Model

You can also access the schema via a Ruby model, with some useful methods for interaction:

```ruby
schema_hash = {
  "fields" => [
      {
          "name" => "id",
          "type" => "string",
          "constraints" => {
            "required" => true,
          }
      },
      {
          "name" => "height",
          "type" => "number"
      }
  ],
  "primaryKey" => "id",
  "foreignKeys" => [
    {
        "fields" => "state",
        "reference" => {
            "datapackage" => "http://data.okfn.org/data/mydatapackage/",
            "resource" => "the-resource",
            "fields" => "state_id"
        }
    }
  ]
}

schema = JsonTableSchema::Schema.new(schema_hash)

schema.headers
#=> ["id", "height"]
schema.required_headers
#=> ["id"]
schema.fields
#=> [{"name"=>"id", "constraints"=>{"required"=>true}, "type"=>"string", "format"=>"default"}, {"name"=>"height", "type"=>"number", "format"=>"default"}]
schema.primary_keys
#=> ["id"]
schema.foreign_keys
#=> [{"fields" => "state", "reference" => { "datapackage" => "http://data.okfn.org/data/mydatapackage/", "resource" => "the-resource", "fields" => "state_id" } } ]
schema.cast('height', '10')
#=> 10.0
schema.get_field('id')
#=> {"name"=>"id", "constraints"=>{"required"=>true}, "type"=>"string", "format"=>"default"}
schema.has_field?('foo')
#=> false
schema.get_type('id')
#=> 'string'
schema.get_fields_by_type('string')
#=> [{"name"=>"id", "constraints"=>{"required"=>true}, "type"=>"string", "format"=>"default"}, {"name"=>"height", "type"=>"string", "format"=>"default"}]
schema.get_constraints('id')
#=> {"required" => true}
schema.convert_row(['string', '10.0'])
#=> ['string', 10.0]
schema.convert([['foo', '12.0'],['bar', '10.0']])
#=> [['foo', 12.0],['bar', 10.0]]
```

When converting a row (using `convert_row`), or a number of rows (using `convert`), by default the converter will fail on the first error it finds. If you pass `false` as the second argument, the errors will be collected into a `errors` attribute for you to review later. For example:

```ruby
schema_hash = {
  "fields" => [
      {
          "name" => "id",
          "type" => "string",
          "constraints" => {
            "required" => true,
          }
      },
      {
          "name" => "height",
          "type" => "number"
      }
  ]
}

schema = JsonTableSchema::Schema.new(schema_hash)

rows = [
  ['foo', 'notanumber'],
  ['bar', 'notanumber'],
  ['wrong column count']
]

schema.convert(rows)
#=> JsonTableSchema::InvalidCast: notanumber is not a number
schema.convert(rows, false)
#=> JsonTableSchema::MultipleInvalid
schema.errors
#=> [#<JsonTableSchema::InvalidCast: notanumber is not a number>, #<JsonTableSchema::InvalidCast: notanumber is not a number>, #<JsonTableSchema::ConversionError: The number of items to convert (1) does not match the number of headers in the schema (2)>]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jsontableschema. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
