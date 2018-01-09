module Revisions
  class PointAtGraphemes < Action::Base
    attr_accessor :ids, :target

    def execute
      connection = Revision.connection

      connection.execute <<-SQL
        delete from #{target.graphemes_revisions_partition_table_name};
      SQL

      connection.raw_connection.copy_data "COPY #{target.graphemes_revisions_partition_table_name} (grapheme_id, revision_id) FROM STDIN CSV" do
        ids.each do |grapheme_id|
          connection.raw_connection.put_copy_data "#{grapheme_id},#{target.id}\n"
        end
      end

      ids
    end
  end
end

