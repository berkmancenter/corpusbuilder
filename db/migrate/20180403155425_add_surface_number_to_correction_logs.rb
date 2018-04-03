class AddSurfaceNumberToCorrectionLogs < ActiveRecord::Migration[5.1]
  def change
    add_column :correction_logs, :surface_number, :integer
  end
end
