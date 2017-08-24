class AddParentIdToRevisions < ActiveRecord::Migration[5.1]
  def change
    add_column :revisions, :parent_id, :uuid
  end
end
