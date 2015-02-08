require 'json'
require 'sequel'

module Thyme
  class Set < Sequel::Model
    plugin :json_serializer

    one_to_many :photos

    dataset_module do
      def newest_first
        reverse_order(:taken_at)
      end
    end

    def to_json(options = {})
      super(
        options.merge(include: [
          :photos_count,
          :thumb_url,
        ])
      )
    end

    private

    def photos_count
      photos.count
    end

    def thumb_url
      photos_dataset.oldest_first.first.small_thumb_url
    end
  end
end
