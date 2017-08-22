class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :title, null: false
      t.string :author
      t.string :authority
      t.date :date
      t.string :editor
      t.string :license
      t.text :notes
      t.string :publisher

      t.timestamps
    end
  end
end
