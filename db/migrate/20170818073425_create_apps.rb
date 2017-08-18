class CreateApps < ActiveRecord::Migration[5.1]
  def change
    create_table :apps, id: :uuid do |t|
      t.string :secret, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
