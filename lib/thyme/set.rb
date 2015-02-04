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

      if set = first(conditions)
        set
      else
        create(conditions)
      end
    end

    def self.newest_first
      all(order: [:taken_at.desc])
    end

    def as_json(options = {})
      super(options).merge(
        photos_count: photos.count,
        thumb_url: photos.oldest_first.first.small_thumb_url
      )
    end

    def update_taken_at!
      self.taken_at = photos.all(fields: [:taken_at]).map(&:taken_at).max
      save
    end
  end
end
