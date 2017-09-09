class AddEditorIdToBranches < ActiveRecord::Migration[5.1]
  def change
    add_column :branches, :editor_id, :uuid, nil: false
  end
end
