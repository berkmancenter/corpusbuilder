class AccuracyDocumentMeasurement < ApplicationRecord
  include Workflow

  belongs_to :accuracy_measurement
  belongs_to :document
  has_many :accuracy_line_measurements

  workflow status: [
    :initial,
    :sampling,
    :ocring,
    :summarizing,
    :ready,
    :error
  ]
end
