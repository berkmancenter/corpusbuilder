class ImageScanUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  process convert: 'png'

  version :preprocessed, if: :has_document? do
    # todo: implement the preprocessing here
    process convert: 'png'
  end

  def has_document? picture
    model.has_document?
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
