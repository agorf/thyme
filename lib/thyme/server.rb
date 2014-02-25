require 'sinatra/base'
require 'thyme/photo'
require 'thyme/photo_wrapper'
require 'thyme/set'

module Thyme
  class Server < Sinatra::Base
    set :root, File.expand_path('.')

    helpers do
      def pluralize(n, singular, plural)
        [n, n == 1 ? singular : plural].join(' ')
      end

      def partial(name, object)
        # prefix last path component with _
        path = name.dup.insert((name.rindex(File::SEPARATOR) || -1) + 1, '_')
        object_key = name.split(File::SEPARATOR).last
        erb path.to_sym, locals: { object_key.to_sym => object }
      end
    end

    get '/' do
      redirect '/set/'
    end

    get '/set/?' do
      @sets = Set.all(order: [:taken_at.desc])
      erb :'set/index'
    end

    get '/set/:id/?' do
      @set = Set.get!(params[:id])
      @photos = @set.photos.all(order: [:taken_at.asc])
      erb :'set/show'
    end

    get '/photo/:id/?' do
      @photo = Thyme::PhotoWrapper.new(Photo.get!(params[:id]))
      erb :'photo/show'
    end
  end
end
