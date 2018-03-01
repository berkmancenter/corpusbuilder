module Revisions
  class PointAtSameGraphemes < Action::Base
    attr_accessor :source, :target

    def execute
      pg_result = Revision.connection.execute <<-SQL
        drop table if exists #{target.graphemes_revisions_partition_table_name};

        create table #{target.graphemes_revisions_partition_table_name}
        as table #{source.graphemes_revisions_partition_table_name};
      SQL

      pg_result.cmd_tuples
    end
  end
end
