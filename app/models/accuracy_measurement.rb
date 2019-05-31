class AccuracyMeasurement < ApplicationRecord
  include Workflow

  belongs_to :ocr_model

  validates :ocr_model, presence: true
  validates :bootstrap_sample_size, presence: true
  validates :bootstrap_number, presence: true

  attr_accessor :document_ids

  workflow status: [
    :initial,
    :sampling,
    :ocring,
    :summarizing,
    :ready,
    :error
  ]
end
