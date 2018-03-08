class AddDirectionToZones < ActiveRecord::Migration[5.1]
  def change
    add_column :zones, :direction, :integer, default: 0
  end
end
