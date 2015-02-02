require 'dm-serializer/to_json'
require 'sinatra/base'
require 'thyme/photo'
require 'thyme/set'

module Thyme
  class Server < Sinatra::Base
    set :root, File.expand_path(File.join(*%w{.. .. ..}), __FILE__)
    set :thumbs_path, File.expand_path(File.join(*%w{.. .. .. public thumbs}),
      __FILE__)

    get '/' do
      send_file File.expand_path('index.html', settings.public_folder)
    end

    get '/sets' do
      pass unless request.accept?('application/json')
      content_type :json
      Set.newest_first.to_json
    end

    get '/photos' do
      pass unless request.accept?('application/json')
      content_type :json
      Photo.all(set: { id: params[:set_id].to_i }).oldest_first.to_json
    end
  end
end
