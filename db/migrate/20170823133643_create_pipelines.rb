class CreatePipelines < ActiveRecord::Migration[5.1]
  def change
    create_table :pipelines, id: :uuid do |t|
      t.string :type, nil: false
      t.integer :status, nil: false
      t.uuid :document_id, nil: false

      t.timestamps
    end
  end
end
