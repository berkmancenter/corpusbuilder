class AddParentIdsToGraphemes < ActiveRecord::Migration[5.1]
  def change
    add_column :graphemes, :parent_ids, :uuid, array: true, default: '{}'
  end
end
