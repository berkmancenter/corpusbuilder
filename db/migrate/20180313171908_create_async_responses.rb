class CreateAsyncResponses < ActiveRecord::Migration[5.1]
  def change
    create_table :async_responses, id: :uuid do |t|
      t.jsonb :payload
      t.integer :status, default: 0
      t.uuid :editor_id, nil: false

      t.timestamps
    end
  end
end
