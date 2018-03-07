class AddPositionWeightToZone < ActiveRecord::Migration[5.1]
  def change
    add_column :zones, :position_weight, 'numeric(12, 6)', nil: false, default: 0
  end
end
