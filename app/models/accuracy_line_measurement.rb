class AccuracyLineMeasurement < ApplicationRecord
  include Workflow

  belongs_to :zone

  serialize :confusion_matrix, ConfusionMatrix

  belongs_to :accuracy_document_measurement

  workflow status: [
    :initial,
    :ocring,
    :summarizing,
    :ready,
    :error
  ]
end
