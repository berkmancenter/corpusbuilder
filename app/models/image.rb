class Image < ApplicationRecord
  mount_uploader :image_scan, ImageScanUploader
  mount_uploader :hocr, HocrUploader

  belongs_to :document, required: false

  validates :image_scan, presence: true

  def has_document?
    document_id.present?
  end

  def preprocessed?
    image_scan.version_exists? :preprocessed
  end

  def ocred?
    hocr.present?
  end

  class Short < Grape::Entity
    expose :id
    expose :name
  end
end
