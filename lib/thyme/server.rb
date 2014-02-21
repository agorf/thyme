require 'sinatra/base'
require 'thyme'

module Thyme
  class Server < Sinatra::Base
    set :views, File.expand_path('views')

    get '/set/?' do
      @sets = Thyme::Set.all(order: [:taken_at.desc])
      erb :'set/index'
    end
  end
end
