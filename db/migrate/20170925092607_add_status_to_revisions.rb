class AddStatusToRevisions < ActiveRecord::Migration[5.1]
  def change
    add_column :revisions, :status, :integer, default: 0, nil: false
  end
end
