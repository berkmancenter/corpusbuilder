class CreateAccuracyMeasurements < ActiveRecord::Migration[5.1]
  def change
    create_table :accuracy_measurements, id: :uuid do |t|
      t.uuid :ocr_model_id, null: false
      t.integer :bootstrap_sample_size, null: false
      t.integer :bootstrap_number, null: false
      t.integer :seed

      t.timestamps
    end
  end
end
