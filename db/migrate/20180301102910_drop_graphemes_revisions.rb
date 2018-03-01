class DropGraphemesRevisions < ActiveRecord::Migration[5.1]
  def change
    drop_table :graphemes_revisions
  end
end
