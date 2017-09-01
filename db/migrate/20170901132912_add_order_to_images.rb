class AddOrderToImages < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :order, :integer, default: 0, nil: false
  end
end
