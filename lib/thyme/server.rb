require 'sinatra/base'
require 'thyme/photo'
require 'thyme/photo_wrapper'
require 'thyme/set'

module Thyme
  class Server < Sinatra::Base
    set :root, File.expand_path(File.join(*%w{.. .. ..}), __FILE__)
    set :thumbs_path, File.expand_path(File.join(*%w{.. .. .. public thumbs}),
      __FILE__)

    helpers do
      def pluralize(n, singular, plural)
        [n, n == 1 ? singular : plural].join(' ')
      end

      def partial(name, locals)
        # prefix last path component with _
        path = name.dup.insert((name.rindex(File::SEPARATOR) || -1) + 1, '_')
        erb path.to_sym, locals: locals
      end
    end

    get '/' do
      redirect '/set/'
    end

    get '/set/?' do
      @sets = Set.all(order: [:taken_at.desc])
      erb :'set/index'
    end

    %w{/set/:id/? /set/:id/photo/?}.each do |path|
      get path do
        @set = Set.get!(params[:id])
        @photos = @set.photos.all(order: [:taken_at.asc])
        erb :'set/show'
      end
    end

    get '/set/:set_id/photo/:id/?' do
      @photo = Thyme::PhotoWrapper.new(Photo.get!(params[:id]))

      if @photo.set_id != params[:set_id].to_i
        halt 404, 'Invalid set or photo id'
      end

      erb :'photo/show'
    end
  end
end
