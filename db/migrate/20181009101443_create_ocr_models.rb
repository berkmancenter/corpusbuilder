class CreateOcrModels < ActiveRecord::Migration[5.1]
  def change
    create_table :ocr_models, id: :uuid do |t|
      t.integer :backend, null: false
      t.string :filename, null: false
      t.string :name, null: false
      t.text :description
      t.string :languages, array: true, null: false
      t.string :scripts, array: true, null: false
      t.string :version_code, null: false

      t.timestamps
    end
  end
end
