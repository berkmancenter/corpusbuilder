class ImageScanUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  version :web do
    process :format_web
  end

  def format_web
    manipulate! do | img |
      img.format( 'jpg' ) do | c |
        c.strip
        c.colorspace 'sRGB'
        c.quality '75'
        c.density '72'
        c.resample '72'
        c.resize '800'
      end

      img
    end
  end

  def has_document? picture
    model.has_document?
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
