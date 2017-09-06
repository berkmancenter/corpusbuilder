class Image < ApplicationRecord
  mount_uploader :image_scan, ImageScanUploader

  belongs_to :document, required: false

  validates :image_scan, presence: true

  class Short < Grape::Entity
    expose :id
    expose :name
  end
end
