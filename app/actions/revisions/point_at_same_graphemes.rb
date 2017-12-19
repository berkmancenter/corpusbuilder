module Revisions
  class PointAtSameGraphemes < Action::Base
    attr_accessor :source, :target

    def execute
      pg_result = Revision.connection.execute <<-SQL
        delete from graphemes_revisions where revision_id = '#{target.id}';

        insert into graphemes_revisions(revision_id, grapheme_id)
        select '#{target.id}' :: uuid,
               joined.grapheme_id
        from (
          select revision_id,
                 grapheme_id
          from graphemes_revisions
          where revision_id = '#{source.id}' :: uuid
        ) joined
      SQL

      pg_result.cmd_tuples
    end
  end
end
