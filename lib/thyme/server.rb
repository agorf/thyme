require 'dm-serializer/to_json'
require 'sinatra/base'
require 'thyme/photo'
require 'thyme/set'

module Thyme
  class Server < Sinatra::Base
    set :root, File.expand_path(File.join(*%w{.. .. ..}), __FILE__)
    set :thumbs_path, File.expand_path(File.join(*%w{.. .. .. public thumbs}),
      __FILE__)

    before do
      pass unless request.accept?('application/json')
      content_type :json
    end

    get '/set' do
      if params[:id]
        Set.get!(params[:id])
      else
        Set.all(order: [:taken_at.desc])
      end.to_json(methods: [:thumb_url, :photos_count])
    end

    get '/photo' do
      if params[:id]
        Photo.get!(params[:id])
      else
        conditions = { order: [:taken_at.asc, :path.asc] }
        conditions[:set_id] = params[:set_id] if params[:set_id]
        Photo.all(conditions)
      end.to_json(methods: [:big_thumb_url, :small_thumb_url])
    end
  end
end
