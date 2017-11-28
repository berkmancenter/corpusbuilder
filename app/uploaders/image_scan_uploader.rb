class ImageScanUploader < CarrierWave::Uploader::Base
  storage :file

  def has_document? picture
    model.has_document?
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
