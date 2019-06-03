class AddAccuracyDocumentMeasurementToAccuracyLineMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_column :accuracy_line_measurements, :accuracy_document_measurement_id, :uuid, nil: false
  end
end
