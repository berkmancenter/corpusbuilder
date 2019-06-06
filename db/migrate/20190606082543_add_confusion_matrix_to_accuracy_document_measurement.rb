class AddConfusionMatrixToAccuracyDocumentMeasurement < ActiveRecord::Migration[5.1]
  def change
    add_column :accuracy_document_measurements, :confusion_matrix, :jsonb
  end
end
