api_spec_fields = [
  schema: 2,
  embedded_schema: 2,
  property: 2,
  property: 3,
  description: 1,
  read_only: 1,
  write_only: 1,
  all_of: 1,
  any_of: 1,
  one_of: 1,
  title: 1,
  additional_properties: 1,
  example: 1,
  schema_type: 1,
  max_items: 1,
  min_items: 1,
  max_properties: 1,
  min_properties: 1,
  validate: 1,
  nullable: 1,
  items: 1,
  not: 1,
  format: 1,
  default: 1,
  deprecated: 1,
  required: 1,
  enum: 1,
  title: 1,
  minimum: 1,
  maximum: 1,
  exclusive_maximum: 1,
  exclusive_minimum: 1,
  max_length: 1,
  min_length: 1,
  pattern: 1,
  unique_items: 1,
  max_properties: 1,
  min_properties: 1,
  discriminator: 1,
  external_docs: 1,
  items: 1
]

# Used by "mix format"
[
  locals_without_parens: api_spec_fields,
  export: [
    locals_without_parens: api_spec_fields
  ]
]
