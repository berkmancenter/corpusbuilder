class CreateAccuracyLineMeasurements < ActiveRecord::Migration[5.1]
  def change
    create_table :accuracy_line_measurements, id: :uuid do |t|
      t.uuid :zone_id, nil: false
      t.integer :status, nil: false, default: 0
      t.json :confusion_matrix, nil: false, default: {}

      t.timestamps
    end
  end
end
