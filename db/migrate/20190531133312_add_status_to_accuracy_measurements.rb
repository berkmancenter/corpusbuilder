class AddStatusToAccuracyMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_column :accuracy_measurements, :status, :integer, default: 0, nil: false
  end
end
