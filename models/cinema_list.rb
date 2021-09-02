# frozen_string_literal: true

require_relative 'cinema'
require_relative 'review'

# The class that contains all films
class CinemaList
  def initialize(films = [])
    @films = films.map do |cinema|
      s = k = 0
      cinema.reviews.each do |_key, rev|
        if rev.mark
          s += rev.mark
          k += 1
        end
      end
      cinema.mark = s / k if k.positive?
      [cinema.id, cinema]
    end.to_h
  end

  def all_films
    @films.values
  end

  def valid_users
    users = {}
    all_films.each do |cinema|
      next unless cinema.reviews.size.positive?

      cinema.reviews.each do |key, _value|
        users[key] = 0 unless users[key]
        users[key] += 1 if cinema.reviews[key].description.size >= 50
      end
    end
    users
  end

  def all_users
    users = []
    all_films.each do |cinema|
      next unless cinema.reviews.size.positive?

      cinema.reviews.each do |_key, _value|
        users.append(_value)
      end
    end
    users
  end

  def count_reviews(month)
    # count = 0
    # all_users.each do |user|
    #   count += 1 if user.date.mon == month
    # end
    # count
    all_users.count{|user| user.date.mon == month}
    # count
  end

  def count_uniq_usurs(month)
    uniq_users = []
    all_users.each do |user|
      uniq_users.append(user.name) if user.date.mon == month && !uniq_users.include?(user.name)
    end
    uniq_users.size
  end

  def count_films(month)
    # count = 0
    # all_films.each do |cinema|
    #   cinema.reviews.each do |_key, rev|
    #     if rev.date.mon == month
    #       count += 1
    #       break
    #     end
    #   end
    # end
    # p count
    buffer = all_films.select{|cinema| cinema.reviews.detect{|k, v| v.date.month == month}}
    p buffer.size
    p all_films.count{|cinema| cinema.reviews.detect{|k, v| v.date.mon == month}}
  end

  def find_top3
    users = valid_users
    top = {}
    (0..2).each do |_i|
      max = 0
      max_key = nil
      users.each do |key, value|
        if value > max && !top.keys.include?(key)
          max = value
          max_key = key
        end
      end
      top[max_key] = max
    end
    top
  end

  def cinema_update_mark(id)
    cinema = @films[id]
    return unless cinema.reviews.size.positive?

    # s = k = 0
    # cinema.reviews.each do |_key, value|
    #   if value.mark
    #     s += value.mark.to_i
    #     k += 1
    #   end
    # end
    # # cinema.mark = s / k.to_f if k.positive?
    # p cinema.reviews.sum{|k, v| v.mark.to_i}/cinema.reviews.count{|k, v| !v.nil?}.to_f if cinema.reviews.count.positive?
    cinema.mark = cinema.reviews.sum{|k, v| v.mark.to_i}/cinema.reviews.count{|k, v| !v.nil?}.to_f if cinema.reviews.count.positive?
  end

  def cinema_by_id(id)
    @films[id]
  end

  def add_cinema(parameters)
    cinema_id = if @films.empty?
                  1
                else
                  @films.keys.max + 1
                end
    @films[cinema_id] = Cinema.new(
      id: cinema_id,
      name: parameters[:name],
      year: parameters[:year],
      genre: parameters[:genre],
      duration: parameters[:duration],
      description: parameters[:description]
    )
    @films[cinema_id].reviews = {}
  end

  def add_review(id, parameters)
    @films[id].reviews[parameters[:name]] = Review.new(
      name: parameters[:name],
      date: parameters[:date],
      description: parameters[:description],
      mark: parameters[:mark]
    )
    cinema_update_mark(id) if parameters[:mark]
  end

  def edit_review(id, name, parameters)
    cinema = @films[id]
    review = cinema.reviews[name]
    parameters.to_h.each do |key, value|
      review[key] = value
    end
    review.name = name
    cinema_update_mark(id) if parameters[:mark]
  end

  def delete_review(id, name)
    cinema = @films[id]
    cinema.reviews.delete(name)
    cinema_update_mark(id)
  end

  def add_real_cinema(cinema)
    @films[cinema.id] = cinema
  end

  def update_cinema(id, parameters)
    cinema = @films[id]
    parameters.to_h.each do |key, value|
      cinema[key] = value
    end
  end

  def delete_cinema(id)
    @films.delete(id)
  end
end
