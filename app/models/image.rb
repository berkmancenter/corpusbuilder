class Image < ApplicationRecord
  mount_uploader :image_scan, ImageScanUploader

  validates :image_scan, presence: true
end
