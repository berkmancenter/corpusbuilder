class AddSurfaceIdToZones < ActiveRecord::Migration[5.1]
  def change
    add_column :zones, :surface_id, :uuid, null: false
  end
end
