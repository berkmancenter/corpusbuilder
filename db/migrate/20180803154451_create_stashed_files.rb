class CreateStashedFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :stashed_files, id: :uuid do |t|
      t.string :attachment

      t.timestamps
    end
  end
end
