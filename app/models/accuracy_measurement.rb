class AccuracyMeasurement < ApplicationRecord
  include Workflow

  belongs_to :ocr_model
  has_many :accuracy_document_measurements

  validates :ocr_model, presence: true
  validates :bootstrap_sample_size, presence: true
  validates :bootstrap_number, presence: true

  attr_accessor :assigned_document_ids

  def document_ids
   assigned_document_ids || accuracy_document_measurements.pluck(:document_id)
  end

  workflow status: [
    :initial,
    :sampling,
    :ocring,
    :summarizing,
    :ready,
    :error
  ]
end
