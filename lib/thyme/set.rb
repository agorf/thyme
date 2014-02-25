require 'data_mapper'

module Thyme
  class Set
    include DataMapper::Resource

    property :id,       Serial
    property :name,     String, length: 4096, unique: true
    property :taken_at, DateTime

    has n, :photos

    def self.find_or_create_by_photo_path(path)
      conditions = { name: path.split(File::SEPARATOR)[-2] }

      if set = Set.first(conditions)
        set
      else
        Set.create(conditions)
      end
    end

    def update_taken_at!
      self.taken_at = photos.all(fields: [:taken_at]).map(&:taken_at).max
      save
    end

    def next
      Set.first(:taken_at.gt => taken_at, order: [:taken_at.asc])
    end

    def prev
      Set.first(:taken_at.lt => taken_at, order: [:taken_at.desc])
    end
  end
end
