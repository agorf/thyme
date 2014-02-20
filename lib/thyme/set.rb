require 'data_mapper'

DataMapper::Model.raise_on_save_failure = true

module Thyme
  class Set
    include DataMapper::Resource

    property :id,   Serial
    property :path, String, length: 4096, unique: true

    has n, :photos
  end
end
