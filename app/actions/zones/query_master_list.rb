module Zones
  class QueryMasterList < Action::Base
    attr_accessor :document

    def execute
      sql = <<-SQL
        select distinct
              zones.id,
              zones.surface_id,
              zones.surface_number,
              zones.position_weight
        from #{ document.master.revision.graphemes_revisions_partition_table_name }
        inner join graphemes
                on graphemes.id = grapheme_id
        inner join (
              select zones.*, surfaces.number as surface_number
              from zones
              inner join surfaces
                      on surfaces.id = zones.surface_id
              where surfaces.document_id = ?
                ) zones
                on zones.id = graphemes.zone_id
        order by zones.surface_number, zones.position_weight
      SQL

      Zone.find_by_sql [ sql, document.id ]
    end
  end
end
