class AddProcessedImageToImages < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :processed_image, :string
  end
end
