class AddProcessedImageToAccuracyLineMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_column :accuracy_line_measurements, :processed_image, :string
  end
end
