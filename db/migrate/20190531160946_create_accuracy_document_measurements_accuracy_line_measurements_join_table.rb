class CreateAccuracyDocumentMeasurementsAccuracyLineMeasurementsJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :accuracy_line_measurements, :accuracy_document_measurements do |t|
      t.index :accuracy_line_measurement_id, name: 'line_document_line_ix'
      t.index :accuracy_document_measurement_id, name: 'line_document_document_ix'
    end
  end
end
