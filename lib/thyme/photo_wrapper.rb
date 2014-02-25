module Thyme
  class PhotoWrapper
    def initialize(photo)
      @photo = photo
    end

    def file_size
      "#{(@photo.size / 1024.0 ** 2).round(2)} MB"
    end

    def dimensions
      [@photo.width, @photo.height].join(' &times; ')
    end

    def aspect_ratio
      gcd = @photo.width.gcd(@photo.height).to_f
      "#{@photo.width / gcd}:#{@photo.height / gcd}".gsub('.0', '')
    end

    def camera
      [@photo.exif['Make'], @photo.exif['Model']].join(' ')
    end

    def method_missing(name, *args, &blk)
      @photo.send(name, *args, &blk) # delegate
    end
  end
end
