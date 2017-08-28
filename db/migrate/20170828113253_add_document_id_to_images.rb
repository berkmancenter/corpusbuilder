class AddDocumentIdToImages < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :document_id, :uuid
  end
end
