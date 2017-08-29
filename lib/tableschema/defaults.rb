module TableSchema
  DEFAULTS = {
    format: 'default',
    type: 'string',
    missing_values: [''],
    group_char: ',',
    decimal_char: '.',
    true_values: ['true', 'True', 'TRUE', '1'],
    false_values: ['false', 'False', 'FALSE', '0'],
    bare_number: true,
  }.freeze
end
