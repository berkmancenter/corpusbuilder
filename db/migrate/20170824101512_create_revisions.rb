class CreateRevisions < ActiveRecord::Migration[5.1]
  def change
    create_table :revisions, id: :uuid do |t|
      t.uuid :document_id, null: false

      t.timestamps
    end
  end
end
