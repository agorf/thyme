require 'dm-serializer/to_json'
require 'sinatra/base'
require 'thyme/photo'
require 'thyme/set'

module Thyme
  class Server < Sinatra::Base
    set :root, File.expand_path(File.join(*%w{.. .. ..}), __FILE__)
    set :thumbs_path, File.expand_path(File.join(*%w{.. .. .. public thumbs}),
      __FILE__)

    get '/sets' do
      pass unless request.accept?('application/json')
      content_type :json
      { sets: Set.newest_first, photos: Photo.all }.to_json
    end
  end
end
