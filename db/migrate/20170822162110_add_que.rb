# frozen_string_literal: true

class AddQue < ActiveRecord::Migration[5.1]
  def self.up
    # The current version as of this migration's creation.
    if defined? Que
      Que.migrate! :version => 3
    end
  end

  def self.down
    # Completely removes Que's job queue.
    if defined? Que
      Que.migrate! :version => 0
    end
  end
end
