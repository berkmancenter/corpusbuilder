class AddModelIdsToDocument < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :ocr_model_ids, :uuid, array: true
    remove_column :documents, :backend
  end
end
