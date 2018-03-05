module Revisions
  class RemoveGraphemes < Action::Base
    attr_accessor :revision_id, :grapheme_ids

    def execute
      if grapheme_ids.present?
        pg_result = Revision.connection.execute <<-SQL
          delete from #{Revision.graphemes_revisions_partition_table_name(revision_id)}
          where grapheme_id in (#{ grapheme_ids.map { |id| "\'#{id}\'" }.join(', ') })
        SQL

        pg_result.cmd_tuples
      end
    end
  end
end

