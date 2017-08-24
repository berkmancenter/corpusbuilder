class CreateGraphemes < ActiveRecord::Migration[5.1]
  def change
    create_table :graphemes, id: :uuid do |t|
      t.uuid :zone_id, null: false
      t.box :area, null: false
      t.column :value, :character, null: false

      t.timestamps
    end
  end
end
