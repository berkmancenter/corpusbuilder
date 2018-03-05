module Revisions
  class PointAtGraphemes < Action::Base
    attr_accessor :ids, :target

    def execute
      connection = Revision.connection

      connection.execute <<-SQL
        delete from #{target.graphemes_revisions_partition_table_name};
      SQL

      Grapheme.copy_data target.graphemes_revisions_partition_table_name, [ :grapheme_id ] do |copy|
        ids.each do |grapheme_id|
          copy.put [ grapheme_id ]
        end
      end

      ids
    end
  end
end

