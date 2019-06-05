class AddBootstrapsToAccuracyDocumentMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_column :accuracy_document_measurements, :bootstraps, :jsonb, default: []
  end
end
