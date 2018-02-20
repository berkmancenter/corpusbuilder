class RemoveQueJobs < ActiveRecord::Migration[5.1]
  def change
    drop_table :que_jobs
  end
end
