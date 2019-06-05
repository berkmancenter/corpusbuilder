class AccuracyMeasurement < ApplicationRecord
  include Workflow

  belongs_to :ocr_model
  has_many :accuracy_document_measurements

  validates :ocr_model, presence: true
  validates :bootstrap_sample_size, presence: true
  validates :bootstrap_number, presence: true

  attr_accessor :assigned_document_ids

  serialize :confusion_matrix, ConfusionMatrix

  def document_ids
    assigned_document_ids || accuracy_document_measurements.pluck(:document_id)
  end

  workflow status: [
    :initial,
    :sampled,
    :scheduled,
    :ocred,
    :ready,
    :error
  ]
end
