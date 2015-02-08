require 'json'
require 'sequel'

module Thyme
  class Photo < Sequel::Model
    THUMBS_PATH = File.expand_path('../../../public/thumbs', __FILE__)

    plugin :json_serializer
    plugin :serialization, :json, :exif

    many_to_one :_set, class: :Set # "set" is reserved by Sequel...
    one_to_one :prev_photo, key: :prev_photo_id, class: self
    one_to_one :next_photo, key: :next_photo_id, class: self

    dataset_module do
      def oldest_first
        order(:taken_at).order_append(:path)
      end
    end

    def big_thumb_url
      thumb_url(:big)
    end

    def small_thumb_url
      thumb_url(:small)
    end

    def to_json(options = {})
      super(
        options.merge(include: [
          :big_thumb_url,
          :filename,
          :lat,
          :lng,
          :small_thumb_url,
        ])
      )
    end

    private

    def basename
      File.basename(path, extname)
    end

    def extname
      File.extname(path)
    end

    def filename
      File.basename(path)
    end

    def lat
      if exif['GPSLatitude']
        exif['GPSLatitude'].to_f
      end
    end

    def lng
      if exif['GPSLongitude']
        exif['GPSLongitude'].to_f
      end
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
