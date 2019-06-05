class AddConfusionMatrixToAccuracyMeasurement < ActiveRecord::Migration[5.1]
  def change
    add_column :accuracy_measurements, :confusion_matrix, :jsonb, nil: false, default:  {}
  end
end
