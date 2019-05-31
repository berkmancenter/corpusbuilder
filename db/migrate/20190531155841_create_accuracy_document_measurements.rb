class CreateAccuracyDocumentMeasurements < ActiveRecord::Migration[5.1]
  def change
    create_table :accuracy_document_measurements, id: :uuid do |t|
      t.uuid :accuracy_measurement_id, nil: false
      t.uuid :document_id, nil: false
      t.integer :status, nil: false, default: 0

      t.timestamps
    end
  end
end
