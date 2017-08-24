class AddGraphemesRevisions < ActiveRecord::Migration[5.1]
  def change
    create_table :graphemes_revisions, id: false do |t|
      t.uuid :grapheme_id, null: false
      t.uuid :revision_id, null: false
    end
  end
end
