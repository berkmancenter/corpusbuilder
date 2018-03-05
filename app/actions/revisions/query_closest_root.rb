module Revisions
  class QueryClosestRoot < Action::Base
    attr_accessor :revision1, :revision2

    validates :revision1, presence: true
    validates :revision2, presence: true

    def execute
      if revision1.id != revision2.id
        Revision.find_by_sql(sql).first
      else
        revision1
      end
    end

    def sql
      <<-SQL
        select revisions.*
        from revisions
        inner join (
          select
            intersecting_id as id,
            max(rank) max_rank
          from (
            select
              path_intersection[1] as intersecting_id,
              array_position(path, path_intersection[1]) + array_position(other_tree_path, path_intersection[1]) as rank
            from (
              with recursive tree(id, origin_id, parent_id, merged_with_id, merge_stop, path) as (
                select id,
                      id as origin_id,
                    parent_id,
                    merged_with_id,
                    false,
                    array[id] as path
                from revisions
                where id in ('#{revision1.id}', '#{revision2.id}')
                union
                select revisions.id,
                       tree.origin_id,
                       revisions.parent_id,
                       revisions.merged_with_id,
                       revisions.merged_with_id is not null,
                       tree.path || revisions.id
                from tree
                inner join revisions
                        on revisions.id = tree.parent_id and (not tree.merge_stop)
                        or revisions.id = tree.merged_with_id and (not tree.merge_stop)
              )
              select tree.path,
                    other_tree.id as other_tree_id,
                    other_tree.path as other_tree_path,
                    uuid_array_intersect(tree.path, other_tree.path) as path_intersection
              from tree
              inner join tree other_tree on tree.origin_id != other_tree.origin_id
            ) paths
            where path_intersection is not null
            group by path, other_tree_path, path_intersection
          ) intersections
          group by intersecting_id
          order by max_rank asc
          limit 1
        ) roots
        on roots.id = revisions.id
      SQL
    end
  end
end
