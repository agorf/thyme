require 'json'
require 'sequel'

module Thyme
  class Set < Sequel::Model
    plugin :json_serializer

    one_to_many :photos
    one_to_one :thumb_photo, class: Photo

    dataset_module do
      def newest_first
        order_append(Sequel.desc(:taken_at))
      end
    end

    def to_json(options = {})
      super(options.merge(include: [:thumb_url]))
    end

    private

    def thumb_url
      thumb_photo.small_thumb_url
    end
  end
end
