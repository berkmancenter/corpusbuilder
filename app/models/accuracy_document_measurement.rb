class AccuracyDocumentMeasurement < ApplicationRecord
  include Workflow

  belongs_to :accuracy_measurement

  workflow status: [
    :initial,
    :sampling,
    :ocring,
    :summarizing,
    :ready,
    :error
  ]
end
