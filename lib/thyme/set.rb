require 'data_mapper'

module Thyme
  class Set
    include DataMapper::Resource

    property :id,   Serial
    property :path, String, length: 4096, unique: true

    has n, :photos

    def self.find_or_create_by_path(path)
      conditions = { path: path.split(File::SEPARATOR)[-2] }

      if set = Thyme::Set.first(conditions)
        set
      else
        Thyme::Set.create(conditions)
      end
    end
  end
end
