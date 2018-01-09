module Revisions
  class RemoveGrapheme < Action::Base
    attr_accessor :revision_id, :grapheme_id

    def execute
      pg_result = Revision.connection.execute <<-SQL
        delete from #{Revision.graphemes_revisions_partition_table_name(revision_id)}
        where grapheme_id = '#{ grapheme_id }' :: uuid
      SQL

      pg_result.cmd_tuples
    end
  end
end
