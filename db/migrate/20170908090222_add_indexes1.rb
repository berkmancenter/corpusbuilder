class AddIndexes1 < ActiveRecord::Migration[5.1]
  def change
    add_index :graphemes, :area, using: 'gist'
    add_index :graphemes, :zone_id
    add_index :zones, :area, using: 'gist'
    add_index :zones, :surface_id
    add_index :surfaces, :area, using: 'gist'
    add_index :graphemes_revisions, [ :grapheme_id, :revision_id ]
  end
end
