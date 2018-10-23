class OcrModelSample < ApplicationRecord
  belongs_to :ocr_model

  mount_uploader :sample_image, OcrModelSampleUploader

  def sample_image_url
    "#{base_url}#{sample_image.url}"
  end
end
