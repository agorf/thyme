require 'data_mapper'

module Thyme
  class Photo
    THUMBS_PATH = File.expand_path('../../../public/thumbs', __FILE__)

    include DataMapper::Resource

    property :id,            Serial
    property :path,          String, length: 4096, unique: true
    property :size,          Integer
    property :width,         Integer
    property :height,        Integer
    property :taken_at,      DateTime
    property :exif,          Json
    property :set_id,        Integer
    property :prev_photo_id, Integer
    property :next_photo_id, Integer

    belongs_to :set
    belongs_to :prev_photo, self, required: false
    belongs_to :next_photo, self, required: false

    def self.oldest_first
      all(order: [:taken_at.asc, :path.asc])
    end

    def as_json(options = {})
      super(options.merge(methods: [:big_thumb_url, :small_thumb_url]))
    end

    def big_thumb_url
      thumb_url(:big)
    end

    def small_thumb_url
      thumb_url(:small)
    end

    private

    def basename
      File.basename(path, extname)
    end

    def extname
      File.extname(path)
    end

    def thumb_filename(suffix)
      "#{basename}_#{suffix}#{extname}"
    end

    def thumb_path(suffix)
      File.join(THUMBS_PATH, thumb_filename(suffix))
    end

    def thumb_url(suffix)
      "/thumbs/#{thumb_filename(suffix)}"
    end
  end
end
