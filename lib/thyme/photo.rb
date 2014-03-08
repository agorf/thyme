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

    def filename
      File.basename(path)
    end

    def generate_thumbs!
      generate_small_thumb!
      generate_big_thumb!
    end

    def next
      set.photos.first(
        :taken_at.gte => taken_at,
        :path.gt => path,
        order: [:taken_at.asc, :path.asc]
      )
    end

    def prev
      set.photos.first(
        :taken_at.lte => taken_at,
        :path.lt => path,
        order: [:taken_at.desc, :path.desc]
      )
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

    def generate_big_thumb!
      generate_thumb!('1000x1000', :big)
    end

    def generate_small_thumb!
      generate_thumb!('200x200', :small)
    end

    def generate_thumb!(size, suffix)
      return if File.exist?(thumb_path(suffix))

      image = MiniMagick::Image.open(path)

      image.combine_options do |c|
        c.auto_orient

        if suffix == :small
          c.resize("#{size}^")
          c.gravity('center')
          c.extent(size)
        elsif suffix == :big
          c.resize(size)
        end
      end

      image.write(thumb_path(suffix))
    end

    def thumb_filename(suffix)
      "#{basename}_#{suffix}#{extname}"
    end

    def thumb_path(suffix)
      File.join(Thyme::Server.thumbs_path, thumb_filename(suffix))
    end
  end
end
