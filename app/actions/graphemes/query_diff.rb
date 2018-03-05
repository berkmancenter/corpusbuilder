module Graphemes
  class QueryDiff < Action::Base
    attr_accessor :revision_left, :revision_right, :reject_mirrored

    validates :revision_right, presence: true

    def execute
      if reject_mirrored == true
        all_diffs.reject { |g| has_mirrored?(g) }
      else
        all_diffs
      end
    end

    def all_diffs
      @_all_diffs ||= -> {
        sql = <<-sql
          with recursive tree(id, parent_id, merged_with_id) as (
            select id,
                parent_id,
                merged_with_id
            from revisions
            where id in ('#{revision_left.id}', '#{revision_right.id}')
            union
            select revisions.id,
                revisions.parent_id,
                revisions.merged_with_id
            from tree
            inner join revisions
                    on    revisions.id = tree.parent_id
                       or revisions.id = tree.merged_with_id
          )
          , corrected_graphemes(id) as (
            select correction_logs.grapheme_id as id
            from tree
            inner join correction_logs
              on correction_logs.revision_id = tree.id
          )
          select g.grapheme_id as id,
                g.inclusion[1],
                g.revision_ids[1] as revision_id,
                graphemes.status,
                graphemes.value,
                graphemes.area,
                graphemes.status,
                graphemes.zone_id,
              graphemes.position_weight,
              graphemes.parent_ids,
              surfaces.number as surface_number
          from (
            select gs.grapheme_id,
                   array_agg(gs.inclusion) as inclusion,
                   array_agg(gs.revision_id) as revision_ids
            from (
              select grapheme_id, 'left' as inclusion, '#{revision_left.id}' as revision_id
              from #{revision_left.graphemes_revisions_partition_table_name}
              inner join corrected_graphemes
                on corrected_graphemes.id = #{revision_left.graphemes_revisions_partition_table_name}.grapheme_id
              union all
              select grapheme_id, 'right' as inclusion, '#{revision_right.id}' as revision_id
              from #{revision_right.graphemes_revisions_partition_table_name}
              inner join corrected_graphemes
                on corrected_graphemes.id = #{revision_right.graphemes_revisions_partition_table_name}.grapheme_id
            ) gs
            group by grapheme_id
            having array_length(array_agg(gs.inclusion), 1) < 2
          ) g
          inner join graphemes
                  on graphemes.id = g.grapheme_id
          inner join zones
                    on zones.id = graphemes.zone_id
          inner join surfaces
                  on surfaces.id = zones.surface_id
          order by surfaces.number, graphemes.position_weight
        sql

        Grapheme.find_by_sql sql
      }.call
    end

    def has_mirrored?(grapheme)
      all_diffs.any? do |other|
        grapheme.inclusion != other.inclusion &&
          grapheme.value == other.value &&
          grapheme.area == other.area &&
          grapheme.surface_number == other.surface_number
      end
    end

    def create_development_dumps?
      true
    end
  end
end
