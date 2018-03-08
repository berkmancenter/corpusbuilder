module Graphemes
  class QueryPage < Action::Base
    attr_accessor :surface, :revision_id, :branch_name, :area

    def execute
      Grapheme.find_by_sql query
    end

    def query
      if surface.present?
        [ with_surface, surface.id ]
      else
        without_surface
      end
    end

    def with_surface
      <<-SQL
        select graphemes.*,
               zones.position_weight as zone_position_weight,
               zones.direction as zone_direction
        from graphemes
        inner join #{revision.graphemes_revisions_partition_table_name}
          on #{revision.graphemes_revisions_partition_table_name}.grapheme_id = graphemes.id
        inner join zones
          on graphemes.zone_id = zones.id
        where zones.surface_id = ?
        order by graphemes.position_weight asc
      SQL
    end

    def without_surface
      <<-SQL
        select graphemes.*,
               zones.position_weight as zone_position_weight,
               zones.direction as zones_direction
        from graphemes
        inner join #{revision.graphemes_revisions_partition_table_name}
          on #{revision.graphemes_revisions_partition_table_name}.grapheme_id = graphemes.id
        inner join zones
          on graphemes.zone_id = zones.id
        order by graphemes.position_weight asc
      SQL
    end

    def revision
      memoized do
        if revision_id.present?
          Revision.find(revision_id)
        else
          Revision.joins(:branches).
                   where(
                     branches: { name: branch_name },
                     document_id: surface.document_id
          ).first
        end
      end
    end
  end
end
