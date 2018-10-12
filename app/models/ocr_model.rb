class OcrModel < ApplicationRecord
  enum backend: [ :tesseract, :kraken ]

  validates :backend, inclusion: { in: backends.keys }

  attr_accessor :file
end
