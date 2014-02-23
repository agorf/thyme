require 'sinatra/base'
require 'thyme'

module Thyme
  class Server < Sinatra::Base
    set :root, File.expand_path('.')

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
      @photo = Photo.get!(params[:id])
      erb :'photo/show'
    end
  end
end
