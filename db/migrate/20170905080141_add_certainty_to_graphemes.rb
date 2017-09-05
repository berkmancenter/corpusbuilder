class AddCertaintyToGraphemes < ActiveRecord::Migration[5.1]
  def change
    add_column :graphemes, :certainty, :'numeric(5, 4)', default: 0.0
  end
end
