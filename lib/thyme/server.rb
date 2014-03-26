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
      def partial(name, locals = {})
        # prefix last path component with _
        path = name.dup.insert((name.rindex(File::SEPARATOR) || -1) + 1, '_')
        erb path.to_sym, locals: locals
      end

      def truncate(text, length)
        if text.length < length
          text
        else
          text[0...length].strip + '...'
        end
      end
    end

    %w{
      /
      /set/?
      /set/:set_id/?
      /set/:set_id/photo/?
      /set/:set_id/photo/:photo_id/?
    }.each do |path|
      get path do
        @sets = Set.all(order: [:taken_at.desc])

        if params[:set_id]
          @set = Set.get!(params[:set_id])

          if params[:photo_id]
            @photo = Photo.get!(params[:photo_id])

            if @photo.set_id != @set.id
              halt 404, 'Invalid set or photo id'
            end

            @photo = Thyme::PhotoWrapper.new(@photo)
          else
            redirect "/set/#{@set.id}/photo/#{@set.photos.first.id}"
          end

          @photos = @set.photos.all(order: [:taken_at.asc, :path.asc])
        end

        erb :index
      end
    end
  end
end
