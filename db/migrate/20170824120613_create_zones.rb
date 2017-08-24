class CreateZones < ActiveRecord::Migration[5.1]
  def change
    create_table :zones, id: :uuid do |t|
      t.uuid :surface_id, null: false
      t.box :area, null: false

      t.timestamps
    end
  end
end
