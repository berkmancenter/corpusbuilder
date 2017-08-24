class CreateBranches < ActiveRecord::Migration[5.1]
  def change
    create_table :branches, id: :uuid do |t|
      t.string :name, null: false
      t.uuid :revision_id, null: false

      t.timestamps
    end
  end
end
