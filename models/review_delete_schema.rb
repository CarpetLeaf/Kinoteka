# frozen_string_literal: true

require 'dry-schema'

ReviewDeleteSchema = Dry::Schema.Params do
  required(:confirmation).filled(true)
end
