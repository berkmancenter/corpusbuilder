class OcrModelSample < ApplicationRecord
  belongs_to :ocr_model

  mount_uploader :sample_image, OcrModelSampleUploader
end
