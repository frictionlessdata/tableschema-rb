# Table Schema
formerly known as JSON Table Schema

[![Travis](https://travis-ci.org/frictionlessdata/tableschema-rb.svg?branch=master)](https://travis-ci.org/frictionlessdata/tableschema-rb)
[![Coveralls](http://img.shields.io/coveralls/frictionlessdata/jsontableschema-rb.svg?branch=master)](https://coveralls.io/r/frictionlessdata/jsontableschema-rb?branch=master)
[![Gem Version](http://img.shields.io/gem/v/jsontableschema.svg)](https://rubygems.org/gems/jsontableschema)
[![SemVer](https://img.shields.io/badge/versions-SemVer-brightgreen.svg)](http://semver.org/)
[![Gitter](https://img.shields.io/gitter/room/frictionlessdata/chat.svg)](https://gitter.im/frictionlessdata/chat)

A utility library for working with [Table Schema](https://specs.frictionlessdata.io/table-schema/) in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tableschema'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tableschema

### Update from `jsontableschema`

The library and its corresponding gem was previously called `jsontableschema`.
Since version 0.3 the library was renamed `tableschema` and has a gem with the same name.

The gem `jsontableschema` is no longer maintained. Here are the steps to transition your code to `tableschema`:

1. Replace
   ```ruby
   gem 'jsontableschema'
   ```
  with

  ```ruby
  gem 'tableschema', '0.3.0'
  ```

2. Replace module name `JsonTableSchema` with module name `TableSchema`. For example:

  ```ruby
  JsonTableSchema::Table.infer_schema(csv)
  ```
  with
  ```ruby
  TableSchema::Table.infer_schema(csv)
  ```

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

csv = 'https://github.com/theodi/jsontableschema.rb/raw/master/spec/fixtures/simple_data.csv' # Can also be a url or array of arrays

table = TableSchema::Table.new(csv, schema)
table.rows
#=> [[1,'foo'],[2,'bar'],[3,'baz']]
```

### Infer a schema

If you don't have a schema for a CSV, and want to generate one, you can infer a schema like so:

```ruby
csv = 'https://github.com/theodi/jsontableschema.rb/raw/master/spec/fixtures/simple_data.csv' # Can also be a url or array of arrays

table = TableSchema::Table.infer_schema(csv)
table.schema
#=> {"fields"=>[{"name"=>"id", "title"=>"", "description"=>"", "type"=>"string", "format"=>"default"}, {"name"=>"title", "title"=>"", "description"=>"", "type"=>"string", "format"=>"default"}]}
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

schema = TableSchema::Schema.new(schema_hash)
schema.valid?
#=> true
```

You can also pass a file path or URL to the initializer:

```ruby
schema = TableSchema::Schema.new('http://example.org/schema.json')
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

schema = TableSchema::Schema.new(schema_hash)

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
schema.cast_row(['string', '10.0'])
#=> ['string', 10.0]
schema.cast([['foo', '12.0'],['bar', '10.0']])
#=> [['foo', 12.0],['bar', 10.0]]
```

When casting a row (using `cast_row`), or a number of rows (using `cast`), by default the converter will fail on the first error it finds. If you pass `false` as the second argument, the errors will be collected into a `errors` attribute for you to review later. For example:

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

schema = TableSchema::Schema.new(schema_hash)

rows = [
  ['foo', 'notanumber'],
  ['bar', 'notanumber'],
  ['wrong column count']
]

schema.cast(rows)
#=> TableSchema::InvalidCast: notanumber is not a number
schema.cast(rows, false)
#=> TableSchema::MultipleInvalid
schema.errors
#=> [#<TableSchema::InvalidCast: notanumber is not a number>, #<TableSchema::InvalidCast: notanumber is not a number>, #<TableSchema::ConversionError: The number of items to convert (1) does not match the number of headers in the schema (2)>]
```

## Field

```ruby
# Init field
field = TableSchema::Field.new({'type': 'number'})

# Cast a value
field.cast_value('12345')
#=> 12345.0
```

Data values can be cast to native Ruby objects with a Field instance. Type instances can be initialized with f[ield descriptors](http://dataprotocols.org/json-table-schema/#field-descriptors). This allows formats and constraints to be defined.

Casting a value will check the value is of the expected type, is in the correct format, and complies with any constraints imposed by a schema. E.g. a date value (in ISO 8601 format) can be cast with a DateType instance. Values that can't be cast will raise an `InvalidCast` exception.

Casting a value that doesn't meet the constraints will raise a `ConstraintError` exception.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/frictionlessdata/tableschema-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
