module Graphemes
  class QueryDiffSurfaceNumbers < Action::Base
    attr_accessor :revision_left, :revision_right

    def execute
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
            select correction_logs.grapheme_id as id,
                  correction_logs.surface_number
            from tree
            inner join correction_logs
              on correction_logs.revision_id = tree.id
          )
        select distinct corrected_graphemes.surface_number from corrected_graphemes
      sql

      Grapheme.connection.execute(sql).to_a.map { |r| r["surface_number"] }.sort
    end
  end
end
