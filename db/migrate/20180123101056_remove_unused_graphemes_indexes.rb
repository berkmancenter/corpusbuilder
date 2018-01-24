class RemoveUnusedGraphemesIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index :graphemes, name: 'index_graphemes_on_area'
    remove_index :graphemes, name: 'index_graphemes_on_zone_id'
  end
end
