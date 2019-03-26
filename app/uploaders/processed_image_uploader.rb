class ProcessedImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  version :web do
    process :format_web
  end

  def format_web
    manipulate! do | img |
      img.format( 'png' ) do | c |
        c.strip
        c.colorspace 'Gray'
        c.quality '100'
        c.density '72'
        c.resample '72'
        c.resize '1600'
      end

      img
    end
  end

end
