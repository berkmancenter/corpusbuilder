class AddTranscriptionToAccuracyLineMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_column :accuracy_line_measurements, :transcription, :text, nil: false, default: ""
  end
end
