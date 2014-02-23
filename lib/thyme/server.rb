require 'sinatra/base'
require 'thyme'

module Thyme
  class Server < Sinatra::Base
    set :root, File.expand_path('.')

    get '/set/?' do
      @sets = Set.all(order: [:taken_at.desc])
      erb :'set/index'
    end
  end
end
