require 'data_mapper'
require 'fileutils'
require 'mini_exiftool'
require 'mini_magick'
require 'thyme/set'

module Thyme
  class Photo
    include DataMapper::Resource

    THUMBS = {
      small: '200x200',
      big:   '1000x1000'
    }
    THUMBS_PATH = 'thumbs'

    FileUtils.mkdir_p THUMBS_PATH

    property :id,       Serial
    property :path,     String, length: 4096, unique: true
    property :size,     Integer
    property :width,    Integer
    property :height,   Integer
    property :taken_at, DateTime
    property :exif,     Json

    belongs_to :set

    def self.create_from_file(path)
      exif = MiniExiftool.new(path)
      open(path) {|f|
        create(
          path:     path,
          size:     f.size,
          width:    exif['ExifImageWidth'],
          height:   exif['ExifImageHeight'],
          taken_at: exif['DateTimeOriginal'],
          exif:     exif.to_hash,
          set:      Set.find_or_create_by_path(path)
        )
      }
    end

    def self.photo?(path)
      jpeg?(path) && File.file?(path)
    end

    def self.jpeg?(path)
      %w{.jpeg .jpg .JPEG .JPG}.include?(File.extname(path))
    end

    def filename
      File.basename(path)
    end

    def generate_thumbs!
      THUMBS.each do |suffix, size|
        generate_thumb!(suffix, size)
      end
    end

    def thumb_path(suffix)
      File.join(THUMBS_PATH, "#{basename}_#{suffix}#{extname}")
    end

    private

    def basename
      File.basename(filename, extname)
    end

    def extname
      File.extname(path)
    end

    def generate_thumb!(suffix, size)
      image = MiniMagick::Image.open(path)
      image.resize(size)
      image.auto_orient
      image.write(thumb_path(suffix))
    end
  end
end
