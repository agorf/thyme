require 'dm-serializer/to_json'
require 'sinatra/base'
require 'thyme/photo'
require 'thyme/set'

module Thyme
  class Server < Sinatra::Base
    set :root, File.expand_path('../../..', __FILE__)

    get '/' do
      send_file File.expand_path('index.html', settings.public_folder)
    end

    get '/sets' do
      pass unless request.accept?('application/json')
      content_type :json
      Set.newest_first.to_json
    end

    get '/set' do
      pass unless request.accept?('application/json')

      if set = Set.get(params[:id])
        content_type :json
        set.to_json
      else
        halt 404, 'Not Found'
      end
    end

    get '/photos' do
      pass unless request.accept?('application/json')
      content_type :json
      Photo.all(set_id: params[:set_id]).oldest_first.to_json
    end

    get '/photo' do
      pass unless request.accept?('application/json')

      if photo = Photo.get(params[:id])
        content_type :json
        photo.to_json
      else
        halt 404, 'Not Found'
      end
    end
  end
end
