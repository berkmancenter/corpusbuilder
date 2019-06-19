class AddGroundTruthToAccuracyLineMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_column :accuracy_line_measurements, :ground_truth, :text, default: ''
  end
end
