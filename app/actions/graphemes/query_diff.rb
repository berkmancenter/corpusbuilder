module Graphemes
  class QueryDiff < Action::Base
    attr_accessor :revision_left, :revision_right

    validates :revision_right, presence: true

    def execute
      sql = <<-sql
        select distinct on (surfaces.number, graphemes.position_weight, g.grapheme_id)
              g.grapheme_id as id,
              g.revision_ids[1] as revision_id,
              case when g.revision_ids[1] = :revision_left_id
              then 'left'
              else 'right'
              end as inclusion,
              graphemes.value,
              graphemes.area,
              graphemes.zone_id,
              graphemes.position_weight,
              graphemes.parent_ids,
              surfaces.number as surface_number
        from (
          select grapheme_id,
                array_agg(revision_id) as revision_ids
          from graphemes_revisions
          where revision_id = :revision_left_id
             or revision_id = :revision_right_id
          group by grapheme_id
          having array_length(array_agg(revision_id), 1) < 2
        ) g
        inner join graphemes
                on graphemes.id = g.grapheme_id
        inner join zones
                on zones.id = graphemes.zone_id
        inner join surfaces
                on surfaces.id = zones.surface_id
        order by surfaces.number, graphemes.position_weight
      sql

      Grapheme.find_by_sql [
        sql, {
          revision_left_id: revision_left.id,
          revision_right_id: revision_right.id
        }
      ]
    end
  end
end
