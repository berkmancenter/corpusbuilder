class AddStatusToBranches < ActiveRecord::Migration[5.1]
  def change
    add_column :branches, :status, :integer, default: 0
  end
end
