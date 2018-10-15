class OcrModel < ApplicationRecord
  enum backend: [ :tesseract, :kraken ]

  validates :backend, inclusion: { in: backends.keys }

  attr_accessor :file

  class Simple < Grape::Entity
    expose :id
    expose :backend
    expose :name
    expose :description
    expose :languages
    expose :scripts
    expose :version_code
  end
end
