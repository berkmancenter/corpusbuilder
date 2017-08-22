class FixDocumentStatus < ActiveRecord::Migration[5.1]
  def change
    remove_column :documents, :status, :string
    add_column :documents, :status, :integer, null: false
  end
end
