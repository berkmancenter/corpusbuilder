class CreateCorrectionLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :correction_logs, id: :uuid do |t|
      t.uuid :grapheme_id, null: false
      t.uuid :revision_id, null: false
      t.uuid :editor_id, null: false
      t.integer :status, null: false

      t.timestamps
    end
  end
end
