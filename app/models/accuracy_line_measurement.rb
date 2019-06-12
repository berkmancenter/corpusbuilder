class AccuracyLineMeasurement < ApplicationRecord
  include Workflow

  mount_uploader :processed_image, ProcessedImageUploader

  belongs_to :zone

  serialize :confusion_matrix, ConfusionMatrix

  belongs_to :accuracy_document_measurement

  workflow status: [
    :initial,
    :ocred,
    :ready,
    :error
  ]
end
