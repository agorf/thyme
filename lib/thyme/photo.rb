require 'data_mapper'
require 'mini_exiftool'
require 'mini_magick'
require 'thyme/set'

module Thyme
  class Photo
    include DataMapper::Resource

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
          set:      Set.find_or_create_by_photo_path(path)
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
      generate_small_thumb!
      generate_big_thumb!
    end

    def thumb_url(suffix)
      "/thumbs/#{thumb_filename(suffix)}"
    end

    private

    def basename
      File.basename(filename, extname)
    end

    def extname
      File.extname(path)
    end

    def generate_small_thumb!
      return if File.exist?(thumb_path('small'))

      image = MiniMagick::Image.open(path)

      image.combine_options do |c|
        c.auto_orient
        c.resize('200x200^')
        c.gravity('center')
        c.extent('200x200')
      end

      image.write(thumb_path('small'))
    end

    def generate_big_thumb!
      return if File.exist?(thumb_path('big'))

      image = MiniMagick::Image.open(path)

      image.combine_options do |c|
        c.auto_orient
        c.resize('1000x1000')
      end

      image.write(thumb_path('big'))
    end

    def thumb_filename(suffix)
      "#{basename}_#{suffix}#{extname}"
    end

    def thumb_path(suffix)
      File.join('public', 'thumbs', thumb_filename(suffix))
    end
  end
end
