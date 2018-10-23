class CreateOcrModelSamples < ActiveRecord::Migration[5.1]
  def change
    create_table :ocr_model_samples, id: :uuid do |t|
      t.uuid :ocr_model_id
      t.string :sample_image

      t.timestamps
    end
  end
end
