require 'digest/md5'
require 'json'
require 'sequel'

module Thyme
  class Photo < Sequel::Model
    THUMBS_PATH = File.expand_path('../../../public/thumbs', __FILE__)
    BIG_THUMB_SIZE = [1000, 1000]
    SMALL_THUMB_SIZE = [200, 200]

    plugin :json_serializer

    many_to_one :_set, class: :Set # "set" is reserved by Sequel...
    one_to_one :prev_photo, key: :prev_photo_id, class: self
    one_to_one :next_photo, key: :next_photo_id, class: self

    dataset_module do
      def newest_first
        order_append(Sequel.desc(:taken_at)).order_append(:path)
      end

      def oldest_first
        order_append(:taken_at).order_append(:path)
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
          :aspect_ratio,
          :big_thumb_height,
          :big_thumb_url,
          :big_thumb_width,
          :filename,
          :orientation,
          :small_thumb_url,
        ])
      )
    end

    private

    def aperture
      super ? super.to_f : super
    end

    def aspect_ratio
      gcd = width.gcd(height).to_f
      [width / gcd, height / gcd]
    end

    def big_thumb_height
      if portrait?
        [height, BIG_THUMB_SIZE.max].min
      else
        ((aspect_ratio[1] / aspect_ratio[0].to_f) * big_thumb_width).round
      end
    end

    def big_thumb_width
      if portrait?
        ((aspect_ratio[0] / aspect_ratio[1].to_f) * big_thumb_height).round
      else
        [width, BIG_THUMB_SIZE.max].min
      end
    end

    def exposure_time
      super ? super.to_f : super
    end

    def filename
      File.basename(path)
    end

    def focal_length
      super ? super.to_f : super
    end

    def identifier
      @identifier ||= Digest::MD5.hexdigest(path)
    end

    def lat
      super ? super.to_f : super
    end

    def lng
      super ? super.to_f : super
    end

    def orientation
      width >= height ? 'landscape' : 'portrait'
    end

    def portrait?
      orientation == 'portrait'
    end

    def thumb_filename(suffix)
      "#{identifier}_#{suffix}.jpg"
    end

    def thumb_path(suffix)
      File.join(THUMBS_PATH, thumb_filename(suffix))
    end

    def thumb_url(suffix)
      "/thumbs/#{thumb_filename(suffix)}"
    end
  end
end
