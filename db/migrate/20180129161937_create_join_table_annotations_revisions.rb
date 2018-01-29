class CreateJoinTableAnnotationsRevisions < ActiveRecord::Migration[5.1]
  def change
    create_join_table :annotations, :revisions do |t|
      # t.index [:annotation_id, :revision_id]
      # t.index [:revision_id, :annotation_id]
    end
  end
end
