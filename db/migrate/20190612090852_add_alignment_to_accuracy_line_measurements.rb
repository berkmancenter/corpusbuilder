class AddAlignmentToAccuracyLineMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_column :accuracy_line_measurements, :alignment, :jsonb, default: []
  end
end
