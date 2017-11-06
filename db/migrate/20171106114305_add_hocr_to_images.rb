class AddHocrToImages < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :hocr, :string
  end
end
