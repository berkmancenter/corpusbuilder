class AddStatusToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :status, :string, null: false
  end
end
