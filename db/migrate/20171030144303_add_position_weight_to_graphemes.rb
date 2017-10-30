class AddPositionWeightToGraphemes < ActiveRecord::Migration[5.1]
  def change
    add_column :graphemes, :position_weight, 'numeric(12, 6)', nil: false
  end
end
