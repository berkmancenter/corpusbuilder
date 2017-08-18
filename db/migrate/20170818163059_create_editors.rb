class CreateEditors < ActiveRecord::Migration[5.1]
  def change
    create_table :editors, id: :uuid do |t|
      t.string :email, null: false
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
