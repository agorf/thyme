require 'logger'
require 'sequel'

DB = Sequel.connect(
  adapter: 'sqlite',
  database: File.expand_path('../../../thyme.db', __FILE__)
)

DB.loggers << Logger.new($stdout) if ENV['THYME_ENV'] == 'development'

DB.create_table? :sets do
  primary_key :id
  String :name, size: 4096, null: false, unique: true
  Time :taken_at
end

DB.create_table? :photos do
  primary_key :id
  foreign_key :set_id, :sets, null: false
  foreign_key :prev_photo_id, :photos, unique: true
  foreign_key :next_photo_id, :photos, unique: true
  String :path, size: 4096, null: false, unique: true
  String :uuid, size: 36, null: false, unique: true
  Integer :size, null: false
  Integer :width, null: false
  Integer :height, null: false
  Time :taken_at
  String :exif
end
