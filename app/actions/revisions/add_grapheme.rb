module Revisions
  class AddGrapheme < Action::Base
    attr_accessor :revision_id, :grapheme_id

    def execute
      pg_result = Revision.connection.execute <<-SQL
        insert into #{Revision.graphemes_revisions_partition_table_name(revision_id)}(revision_id, grapheme_id)
        values ('#{ revision_id }' :: uuid, '#{ grapheme_id }' :: uuid)
      SQL

      pg_result.cmd_tuples
    end
  end
end
