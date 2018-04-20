module Graphemes
  class QueryLine < Action::Base
    attr_accessor :zone, :document, :revision

    def execute
      sql = <<-SQL
        select graphemes.*
        from graphemes
        inner join #{ revision.graphemes_revisions_partition_table_name }
                on #{ revision.graphemes_revisions_partition_table_name }.grapheme_id = graphemes.id
        where graphemes.zone_id = ?
      SQL

      Grapheme.find_by_sql [ sql, zone.id ]
    end
  end
end
