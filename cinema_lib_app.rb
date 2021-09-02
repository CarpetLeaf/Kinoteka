# frozen_string_literal: true

require 'date'
require 'forme'
require 'roda'

require_relative 'models'

# The application class
class CinemaApplication < Roda
  opts[:root] = __dir__
  plugin :environments
  plugin :forme
  plugin :hash_routes
  plugin :path
  plugin :render
  plugin :status_handler
  plugin :view_options

  configure :development do
    plugin :public
    opts[:serve_static] = true
  end

  opts[:films] = Reader.read_cinema
  opts[:films].count_films(5)
  # opts[:films].cinema_update_mark(1)

  status_handler(404) do
    view('not_found')
  end

  route do |r|
    r.public if opts[:serve_static]

    r.root do
      r.redirect '/films'
    end

    r.on 'films' do
      r.is do
        @films = opts[:films].all_films
        view('films')
      end

      r.on Integer do |id|
        @cinema = opts[:films].cinema_by_id(id)
        next if @cinema.nil?

        r.is do
          view('cinema')
        end

        r.on 'add_review' do
          r.get do
            @parameters = {}
            view('add_review')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(ReviewFormSchema.call(r.params))
            if @parameters.success?
              opts[:films].add_review(@cinema.id, @parameters)
              r.redirect "/films/#{@cinema.id}"
            else
              view('add_review')
            end
          end
        end

        r.on 'edit_review_list' do
          r.is do
            @parameters = @cinema.to_h
            view('edit_review_list')
          end

          r.on String do |name|
            r.get do
              @parameters = @cinema.reviews[name].to_h
              view('edit_review')
            end

            r.post do
              @parameters = DryResultFormeWrapper.new(ReviewFormSchema.call(r.params))
              if @parameters.success?
                opts[:films].edit_review(@cinema.id, name, @parameters)
                r.redirect "/films/#{@cinema.id}/edit_review_list"
              else
                view('edit_review')
              end
            end
          end
        end

        r.on 'delete_review_list' do
          r.is do
            @parameters = @cinema.to_h
            view('delete_review_list')
          end

          r.on String do |name|
            @name = name
            r.get do
              @parameters = @cinema.reviews[name].to_h
              view('delete_review')
            end

            r.post do
              @parameters = DryResultFormeWrapper.new(ReviewDeleteSchema.call(r.params))
              if @parameters.success?
                opts[:films].delete_review(@cinema.id, name)
                r.redirect "/films/#{@cinema.id}/delete_review_list"
              else
                view('delete_review')
              end
            end
          end
        end

        r.on 'edit' do
          r.get do
            @parameters = @cinema.to_h
            view('cinema_edit')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(CinemaFormSchema.call(r.params))
            if @parameters.success?
              opts[:films].update_cinema(@cinema.id, @parameters)
              r.redirect "/films/#{@cinema.id}"
            else
              view('cinema_edit')
            end
          end
        end

        r.on 'delete' do
          r.get do
            @parameters = {}
            view('delete_cinema')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(CinemaDeleteSchema.call(r.params))
            if @parameters.success?
              opts[:films].delete_cinema(@cinema.id)
              r.redirect('/films')
            else
              view('delete_cinema')
            end
          end
        end
      end

      r.on 'statistics' do
        @info = []
        (1..12).each do |m|
          buf = [opts[:films].count_reviews(m), opts[:films].count_films(m), opts[:films].count_uniq_usurs(m)]
          @info[m - 1] = buf
        end
        view('statistics')
      end

      r.on 'new' do
        r.get do
          @parameters = {}
          view('new_cinema')
        end

        r.post do
          @parameters = DryResultFormeWrapper.new(CinemaFormSchema.call(r.params))
          if @parameters.success?
            opts[:films].add_cinema(@parameters)
            r.redirect '/films'
          else
            view('new_cinema')
          end
        end
      end

      r.on 'films_sort_mark' do
        @films = opts[:films].all_films
        @films = @films.sort_by{|x| x.mark.to_i}
        view('films_sort_mark')
      end

      r.on 'films_sort_rev_cnt' do
        @films = opts[:films].all_films
        @films = @films.sort_by{|x| x.reviews.size}
        view('films_sort_rev_cnt')
      end

      r.on 'films_sort_last_upd' do
        @films = opts[:films].all_films
        @films = @films.sort_by{|x| x.reviews.first[1].date}
        view('films_sort_last_upd')
      end

      r.on 'top_list' do
        @top = opts[:films].find_top3
        view('top_list')
      end

      r.on 'delete_cinema_list' do
        @films = opts[:films].all_films
        view('delete_cinema_list')
      end

      r.on 'edit_cinema_list' do
        @films = opts[:films].all_films
        view('edit_cinema_list')
      end
    end
  end
end
