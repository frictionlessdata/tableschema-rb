# tableschema-rb

[![Travis](https://travis-ci.org/frictionlessdata/tableschema-rb.svg?branch=master)](https://travis-ci.org/frictionlessdata/tableschema-rb)
[![Coveralls](https://coveralls.io/repos/github/frictionlessdata/tableschema-rb/badge.svg?branch=master)](https://coveralls.io/github/frictionlessdata/tableschema-rb?branch=master)
[![Gem Version](http://img.shields.io/gem/v/tableschema.svg)](https://rubygems.org/gems/tableschema)
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
    JsonTableSchema::Table.new(source, schema: schema)
    ```
    with
    ```ruby
    TableSchema::Table.new(source, schema: schema)
    ```

## Usage

### Parse a CSV

Validate and cast data from a CSV as described by a schema.

```ruby
schema = {
    fields: [
        {
            name: 'id',
            title: 'Identifier',
            type: 'integer'
        },
        {
            name: 'title',
            title: 'Title',
            type: 'string'
        }
    ]
}

source = 'https://github.com/frictionlessdata/tableschema-rb/raw/master/spec/fixtures/simple_data.csv'

table = TableSchema::Table.new(source, schema: schema)

# Iterate through rows
table.iter{ |row| print row }
# [1, "foo"]
# [2, "bar"]
# [3, "baz"]

# Read the entire CSV in memory
table.read
#=> [[1,'foo'],[2,'bar'],[3,'baz']]
```

Both `iter` and `read` take the optional parameters:
- `keyed`: boolean, default: `false` - return the rows as Hashes with headers as keys
- `cast`: boolean, default `true` - cast values for each row
- `limit`: integer, default `nil` - stop at this many rows

### Infer a schema

If you don't have a schema for a CSV, and want to generate one, you can infer a schema like so:

```ruby
source = 'https://github.com/frictionlessdata/tableschema-rb/raw/master/spec/fixtures/simple_data.csv' # Can also be a url or array of arrays

table = TableSchema::Table.new(source)
table.infer()
table.schema
#=> {:fields=>[{:name=>"id", :title=>"", :description=>"", :type=>"integer", :format=>"default", :constraints=>{}}, {:name=>"title", :title=>"", :description=>"", :type=>"string", :format=>"default", :constraints=>{}}]}
```

### Build a Schema

You can also build a schema from scratch or modify an existing one:

```ruby
schema = TableSchema::Schema.new({
  fields: [],
})

# Add a field
schema.add_field({
  name: 'id',
  type: 'string',
  constraints: {
    required: true,
  }
})

# Remove a field
schema.remove_field('id')
```

`add_field` will ignore the updates if the updated version of the the schema fails [validation](#validate-a-schema).
If you wish to prevent an invalid schema from being created or updated by raising validation errors, you can pass the `strict: true` argument to the Schema initializer:

```ruby
schema = TableSchema::Schema.new(schema_hash, strict: true)
```

There are multiple methods to inspect a schema:

```ruby
schema_hash = {
  fields: [
    {
      name: 'id',
      type: 'string',
      constraints: {
        required: true,
      },
    },
    {
      name: 'height',
      type: 'number',
    },
    {
      name: 'state',
    },
  ],
  primaryKey: 'id',
  foreignKeys: [
    {
      fields: 'state',
      reference: {
          resource: 'the-resource',
          fields: 'state_id',
      },
    },
  ]
}
schema = TableSchema::Schema.new(schema_hash)

schema.field_names
#=> ["id", "height"]
schema.fields
#=> [{:name=>"id", :type=>"string", :constraints=>{:required=>true}, :format=>"default"}, {:name=>"height", :type=>"number", :format=>"default", :constraints=>{}}]
schema.primary_key
#=> ["id"]
schema.foreign_keys
# => [{:fields=>"state", :reference=>{:resource=>"the-resource", :fields=>"state_id"}}]
schema.get_field('id')
# => {:name=>"id", :type=>"string", :constraints=>{:required=>true}, :format=>"default"}
```

#### Cast row

To check if a given set of values complies with the schema, you can use `cast_row`:

```
schema.cast_row(['string', '10.0', 'State'])
#=> ['string', 10.0, 'State']
```

By default the converter will fail on the first error it finds. However, by passing `fail_fast: false` as the second argument the errors will be collected into an `exception.errors` attribute for you to review later. For example:

```ruby
row = [3, 'nan', 'State']

schema.cast_row(row)
#=> TableSchema::InvalidCast: 3 is not a string
begin
  schema.cast_row(row, fail_fast: false)
rescue TableSchema::MultipleInvalid => exception
  exception.errors
end
#=> #<Set: {#<TableSchema::InvalidCast: 3 is not a string>,
            #<TableSchema::InvalidCast: nan is not a number>}>
```

### Validate a schema

To make sure a schema complies with [Table Schema spec](https://specs.frictionlessdata.io/table-schema), we validate each custom schema against the
official [Table Schema schema](https://specs.frictionlessdata.io/schemas/table-schema.json):

```ruby
schema_hash = {
  fields: [
      { name: 'id' },
  ]
}
schema = TableSchema::Schema.new(schema_hash)
schema.validate
#=> true
```

If the schema is invalid, you can access the errors via the `errors` attribute

```ruby
schema_hash = {
  fields: [
    {
      name: 'id',
      title: 'Identifier',
      type: 'integer'
    },
    {
      name: 'title',
      title: 'Title',
      type: 'string'
    }
  ],
  primaryKey: 'identifier'
}

schema = TableSchema::Schema.new(schema_hash)
schema.validate
#=> false
schema.errors
#=> #<Set: {"The TableSchema primaryKey value `identifier` is not found in any of the schema's field names"}>

# Raise error if validation fails
schema.validate!
#=> TableSchema::SchemaException: The TableSchema primaryKey value `identifier` is not found in any of the schema's field names
```

## Field

Data values can be cast to native Ruby objects with a Field instance. This allows formats and constraints to be defined for the field in the [field descriptor](https://specs.frictionlessdata.io/table-schema/#field-descriptors):

```ruby
# Init field
field = TableSchema::Field.new({
  name: 'over_1700',
  type: 'number',
  constraints: {
    minimum: '1700',
  },
})

# Cast a value
field.cast_value('12345')
#=> 12345.0
```

Casting a value will check the value is of the expected `type`, is in the correct `format`, and complies with any `constraints` imposed in the descriptor.

Value that can't be cast will raise an `InvalidCast` exception.

Casting a value that doesn't meet the constraints will raise a `ConstraintError` exception.

```ruby
field.cast_value('nan')
#=> TableSchema::InvalidCast: nan is not a number
field.cast_value('1200')
#=> TableSchema::ConstraintError: The field `over_1700` must not be less than 1700
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/frictionlessdata/tableschema-rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
