class AddBackendToDocument < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :backend, :string, default: 'tesseract'
  end
end
