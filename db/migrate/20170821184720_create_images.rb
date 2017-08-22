class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images, id: :uuid do |t|
      t.string :name
      t.string :image_scan

      t.timestamps
    end
  end
end
