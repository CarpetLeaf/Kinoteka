# frozen_string_literal: true

require_relative 'review'

# The class that contains all films
class Reviews
  def initialize(reviews = [])
    @reviews = reviews.map do |rev|
      [rev.name, rev]
    end.to_h
  end

  def all_reviews
    @reviews.values
  end

  def review_by_name(name)
    @reviews[name]
  end

  def add_review(name, parameters)
    @reviews[name] = Review.new(name: name, **parameters.to_h)
    @reviews[name]
  end

  def add_real_review(review)
    @reviews[review.name] = review
  end

  def update_review(name, parameters)
    review = @reviews[name]
    parameters.to_h.each do |key, value|
      reviews[key] = value
    end
  end

  def delete_review(name)
    @reviews.delete(name)
  end
end
