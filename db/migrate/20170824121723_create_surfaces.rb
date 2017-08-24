class CreateSurfaces < ActiveRecord::Migration[5.1]
  def change
    create_table :surfaces, id: :uuid do |t|
      t.uuid :document_id, null: false
      t.box :area, null: false
      t.integer :number, null: false
      t.uuid :image_id, null: false

      t.timestamps
    end
  end
end
