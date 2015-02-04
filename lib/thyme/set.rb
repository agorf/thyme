require 'data_mapper'

module Thyme
  class Set
    include DataMapper::Resource

    property :id,       Serial
    property :name,     String, length: 4096, unique: true
    property :taken_at, DateTime

    has n, :photos

    def self.newest_first
      all(order: [:taken_at.desc])
    end

    def as_json(options = {})
      super(options).merge(
        photos_count: photos.count,
        thumb_url: photos.oldest_first.first.small_thumb_url
      )
    end
  end
end
