require 'data_mapper'
require 'fileutils'
require 'mini_exiftool'
require 'mini_magick'

DataMapper::Model.raise_on_save_failure = true

module Thyme
  class Photo

    include DataMapper::Resource

    THUMBS_PATH = 'thumbs'

    FileUtils.mkdir_p THUMBS_PATH

    property :id,       Serial
    property :path,     String, length: 4096
    property :size,     Integer
    property :width,    Integer
    property :height,   Integer
    property :taken_at, DateTime
    property :exif,     Json

    def self.create_from_file(path)
      exif = MiniExiftool.new(path)
      open(path) {|f|
        create(
          path:     path,
          size:     f.size,
          width:    exif['ExifImageWidth'],
          height:   exif['ExifImageHeight'],
          taken_at: exif['DateTimeOriginal'],
          exif:     exif.to_hash
        )
      }
    end

    def filename
      File.basename(path)
    end

    def generate_thumbs!
      generate_small_thumb!
      generate_big_thumb!
    end

    private

    def basename
      File.basename(filename, extname)
    end

    def extname
      File.extname(path)
    end

    def generate_thumb!(size)
      image = MiniMagick::Image.open(path)
      image.resize(size)
      image.auto_orient
      image.write(thumb_path(size))
    end

    def generate_small_thumb!
      generate_thumb!('200x200')
    end

    def generate_big_thumb!
      generate_thumb!('1000x1000')
    end

    def thumb_path(size)
      File.join(THUMBS_PATH, "#{basename}_#{size}#{extname}")
    end
  end
end

DataMapper.finalize
