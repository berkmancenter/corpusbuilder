class AddSurfaceNumberToAnnotation < ActiveRecord::Migration[5.1]
  def change
    add_column :annotations, :surface_number, :int
  end
end
