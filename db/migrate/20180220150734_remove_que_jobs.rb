class RemoveQueJobs < ActiveRecord::Migration[5.1]
  def change
    if defined? Que
      drop_table :que_jobs
    end
  end
end
