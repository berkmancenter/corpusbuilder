module Revisions
  class PointAtGraphemes < Action::Base
    attr_accessor :ids, :target

    def execute
      connection = Revision.connection

      connection.execute <<-SQL
        delete from #{target.graphemes_revisions_partition_table_name};
      SQL

      copy_sql = "COPY #{target.graphemes_revisions_partition_table_name} (grapheme_id) FROM STDIN CSV"

      connection.raw_connection.copy_data copy_sql do
        ids.each do |grapheme_id|
          connection.raw_connection.put_copy_data "#{grapheme_id}\n"
        end
      end

      Rails.logger.info copy_sql
      Rails.logger.info "(... #{ ids.count } grapheme ids being copied ...)"

      ids
    end
  end
end

