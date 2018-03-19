module Revisions
  class QueryClosestRoot < Action::Base
    attr_accessor :revision1, :revision2

    validates :revision1, presence: true
    validates :revision2, presence: true

    def execute
      Revision.find(closest_node_id)
    end

    def closest_node_id
      memoized do
        Revision.connection.execute(sql).to_a.first['id']
      end
    end

    def sql
      <<-SQL
        with recursive ancestors1 as (
          select revisions.id, revisions.parent_id, revisions.merged_with_id, 1 as rank
          from revisions
          where revisions.id = '#{revision1.id}'
          union
          select revisions.id, revisions.parent_id, revisions.merged_with_id, ancestors1.rank + 1
          from revisions
          inner join ancestors1
                  on ancestors1.parent_id = revisions.id
                  or ancestors1.merged_with_id = revisions.id
        ),
        ancestors2 as (
          select revisions.id, revisions.parent_id, revisions.merged_with_id, 1 as rank
          from revisions
          where revisions.id = '#{revision2.id}'
          union
          select revisions.id, revisions.parent_id, revisions.merged_with_id, ancestors2.rank + 1
          from revisions
          inner join ancestors2
                  on ancestors2.parent_id = revisions.id
                  or ancestors2.merged_with_id = revisions.id
        )
        select ancestors1.id,
              ancestors1.parent_id,
              ancestors1.rank as rank1,
              ancestors2.rank as rank2
        from ancestors1
        inner join ancestors2
                on ancestors2.id = ancestors1.id
        order by ancestors1.rank * ancestors2.rank asc
        limit 1
      SQL
    end
  end
end
