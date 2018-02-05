class AddStatusToAnnotations < ActiveRecord::Migration[5.1]
  def change
    add_column :annotations, :status, :integer, default: 0, nil: false
  end
end
