# frozen_string_literal: true

require 'dry-schema'

require_relative 'schema_types'

ReviewFormSchema = Dry::Schema.Params do
  required(:name).filled(SchemaTypes::StrippedString)
  required(:description).filled(SchemaTypes::StrippedString)
  required(:mark).maybe(:integer, gteq?: 0, lteq?: 10)
  required(:date).filled(:date)
end
