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
          select stats.*
          from (
            with recursive tree(id, parent_id, path) as (
              select id,
                  parent_id,
                  array[id] as path
              from revisions
              where id in ('#{revision1.id}', '#{revision2.id}')
              union
              select revisions.id,
                  revisions.parent_id,
                  revisions.id || tree.path
              from tree
              inner join revisions
                      on revisions.id = tree.parent_id
            )
            select id,
                  count(path) as branches_count,
                  array_length(string_to_array(array_to_string(array_agg(array_to_string(path, ',')), ','), ','), 1) as branches_length
            from tree
            group by id
          ) stats
          order by stats.branches_count desc, stats.branches_length asc
          limit 1
        ) roots
        on roots.id = revisions.id;
      SQL
    end
  end
end
