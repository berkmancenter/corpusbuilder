class ProcessedImageUploader < CarrierWave::Uploader::Base
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

end
