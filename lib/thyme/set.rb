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
  end
end
