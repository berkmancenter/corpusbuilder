module Graphemes
  class QueryMergeExcludes < Action::Base
    attr_accessor :branch_left, :branch_right

    validates :branch_left, presence: true
    validates :branch_right, presence: true

    def execute
      @_excludes ||= -> {
        sql = <<-SQL
          with lone_wolfs as (
              select singles.inclusion, graphemes.*
              from graphemes
              inner join (
                select gs.grapheme_id, array_agg(gs.inclusion) as inclusion
                from (
                  select grapheme_id, 'left' as inclusion
                  from #{ branch_left.revision.graphemes_revisions_partition_table_name }
                  union all
                  select grapheme_id, 'right' as inclusion
                  from #{ branch_right.revision.graphemes_revisions_partition_table_name }
                ) gs
                group by grapheme_id
                having array_length(array_agg(gs.inclusion), 1) < 2
              ) singles
              on singles.grapheme_id = graphemes.id
          )
          select case when lefties.created_at < righties.created_at
                 then lefties.id else righties.id
                 end as excluded_id,
                 lefties.area as lefties_area,
                 righties.area as righties_area,
                 lefties.value as lefties_value,
                 righties.value as righties_value,
                 lefties.created_at as lefties_created_at,
                 righties.created_at as righties_created_at,
                 lefties.id as lefties_id,
                 righties.id as righties_id
          from (
            select * from lone_wolfs where inclusion[1] = 'left'
          ) lefties
          inner join (
            select * from lone_wolfs where inclusion[1] = 'right'
          ) righties
          on coalesce(area(lefties.area # righties.area), 0) > 0
        SQL

        Grapheme.find_by_sql(sql).map(&:excluded_id)
      }.call
    end
  end
end
