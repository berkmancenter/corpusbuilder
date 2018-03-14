module Graphemes
  class QueryDiff < Action::Base
    attr_accessor :revision_left, :revision_right, :reject_mirrored

    validates :revision_right, presence: true

    def execute
      if reject_mirrored == true
        without_mirrored all_diffs
      else
        all_diffs
      end
    end

    def all_diffs
      memoized do
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
              union
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
      end
    end

    def without_mirrored(diffs)
      left_set = Set.new
      right_set = Set.new

      for diff in diffs
        if diff.inclusion == 'left'
          left_set.add(diff)
        else
          left_set.add(diff)
        end
      end

      for left in left_set
        for right in right_set
          if left.value == right.value &&
              left.area == right.area &&
              left.surface_number == right.surface_number
            right_set.delete(right)
          end
        end
      end

      left_set.to_a + right_set.to_a
    end

    def create_development_dumps?
      true
    end
  end
end
