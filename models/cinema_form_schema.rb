# frozen_string_literal: true

require 'dry-schema'

require_relative 'schema_types'

CinemaFormSchema = Dry::Schema.Params do
  required(:name).filled(SchemaTypes::StrippedString)
  required(:year).filled(:integer, gt?: 0, lteq?: Date.today.year)
  required(:genre).filled(SchemaTypes::StrippedString)
  required(:duration).filled(:integer, gt?: 0)
  required(:description).filled(SchemaTypes::StrippedString)
end
