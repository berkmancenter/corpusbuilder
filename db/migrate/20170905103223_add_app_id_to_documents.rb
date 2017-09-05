class AddAppIdToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :app_id, :uuid, null: false
  end
end
