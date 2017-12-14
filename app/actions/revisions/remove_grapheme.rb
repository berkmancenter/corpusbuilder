module Revisions
  class RemoveGrapheme < Action::Base
    attr_accessor :revision_id, :grapheme_id

    def execute
      pg_result = Revision.connection.execute <<-SQL
        delete from graphemes_revisions
        where
            revision_id = '#{ revision_id }' :: uuid
        and grapheme_id = '#{ grapheme_id }' :: uuid
      SQL

      pg_result.cmd_tuples
    end
  end
end
