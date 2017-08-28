class AddDataToPipelines < ActiveRecord::Migration[5.1]
  def change
    add_column :pipelines, :data, :jsonb, default: {}
  end
end
