class OcrModelSampleUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file
  process :convert => 'png'

  process resize_to_fill: [ 0, 35]

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
