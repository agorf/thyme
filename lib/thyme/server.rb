require 'sinatra/base'

module Thyme
  class Server < Sinatra::Base
    get '/' do
      'Hello, World!'
    end
  end
end
