require 'sinatra/base'
require 'thyme/photo'
require 'thyme/set'

module Thyme
  class Server < Sinatra::Base
    set :root, File.expand_path('../../..', __FILE__)

    helpers do
      def require_json
        pass unless request.accept?('application/json')
      end
    end

    get '/', provides: :html do
      send_file File.expand_path('index.html', settings.public_folder)
    end

    get '/sets', provides: :json do
      Set.newest_first.to_json
    end

    # GET /set?id=:id
    get '/set', provides: :json do
      require_json

      if set = Set[params[:id]]
        set.to_json
      else
        halt 404, '{}'
      end
    end

    # GET /photos?set_id=:set_id
    get '/photos', provides: :json do
      require_json
      Photo.where(set_id: params[:set_id]).oldest_first.to_json
    end

    # GET /photo?id=:id
    get '/photo', provides: :json do
      require_json

      if photo = Photo[params[:id]]
        photo.to_json
      else
        halt 404, '{}'
      end
    end
  end
end
