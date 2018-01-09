module Revisions
  class PointAtSameGraphemes < Action::Base
    attr_accessor :source, :target

    def execute
      pg_result = Revision.connection.execute <<-SQL
        delete from #{target.graphemes_revisions_partition_table_name};

        insert into #{target.graphemes_revisions_partition_table_name}(revision_id, grapheme_id)
        select '#{target.id}' :: uuid,
               joined.grapheme_id
        from (
          select grapheme_id
          from #{source.graphemes_revisions_partition_table_name}
        ) joined
      SQL

      pg_result.cmd_tuples
    end
  end
end
