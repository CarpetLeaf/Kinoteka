# frozen_string_literal: true

require 'dry-schema'

CinemaDeleteSchema = Dry::Schema.Params do
  required(:confirmation).filled(true)
end
