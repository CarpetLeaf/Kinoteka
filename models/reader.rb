# frozen_string_literal: true

require_relative 'cinema'
require_relative 'cinema_list'
require 'csv'
require 'date'

# Reader
module Reader
  CINEMA_FILE = File.expand_path('../data/films.csv', __dir__)
  REVIEW_FILE = File.expand_path('../data/reviews.csv', __dir__)

  def self.read_cinema
    cinema_list = CinemaList.new
    CSV.foreach(CINEMA_FILE, col_sep: ';') do |row|
      parameters = { name: row[0], year: row[1].to_i, genre: row[2], duration: row[3].to_i, description: row[4] }
      cinema_list.add_cinema(parameters)
    end
    cinema_list.all_films.each do |cinema|
      cinema.reviews = {}
    end
    CSV.foreach(REVIEW_FILE, col_sep: ';') do |row|
      review = Review.new(name: row[1], date: Date.parse(row[2]), description: row[3], mark: row[4])
      cinema_list.cinema_by_id(row[0].to_i).reviews[row[1]] = review
    end
    cinema_list.all_films.each do |cinema|
      cinema_list.cinema_update_mark(cinema.id)
    end
    cinema_list
  end
end
