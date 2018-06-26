class AddLanguagesToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :languages, :string, array: true
  end
end
