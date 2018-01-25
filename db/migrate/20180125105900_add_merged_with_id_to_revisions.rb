class AddMergedWithIdToRevisions < ActiveRecord::Migration[5.1]
  def change
    add_column :revisions, :merged_with_id, :uuid
  end
end
