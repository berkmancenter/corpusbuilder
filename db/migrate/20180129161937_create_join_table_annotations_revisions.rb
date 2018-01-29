class CreateJoinTableAnnotationsRevisions < ActiveRecord::Migration[5.1]
  def change
    create_table :annotations_revisions, id: false do |t|
      t.uuid :annotation_id, null: false
      t.uuid :revision_id, null: false
    end
  end
end
