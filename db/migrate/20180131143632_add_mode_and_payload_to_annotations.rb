class AddModeAndPayloadToAnnotations < ActiveRecord::Migration[5.1]
  def change
    add_column :annotations, :mode, :integer, default: 0, nil: false
    add_column :annotations, :payload, :json, default: {}
  end
end
