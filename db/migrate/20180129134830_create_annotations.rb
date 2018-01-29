class CreateAnnotations < ActiveRecord::Migration[5.1]
  def change
    create_table :annotations, id: :uuid do |t|
      t.text :content
      t.uuid :editor_id
      t.column :areas, :box, array: true

      t.timestamps
    end
  end
end
