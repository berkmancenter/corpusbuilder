module Graphemes
  class QueryDiffSurfaceNumbers < Action::Base
    attr_accessor :revision_left, :revision_right

    def execute
      sql = <<-sql
        select distinct surface_number
        from correction_logs
        where correction_logs.revision_id in (#{ path_ids.map { |p| "'#{p}'" }.join(', ') })
      sql

      if path_ids.present?
        Grapheme.connection.execute(sql).to_a.map { |r| r["surface_number"] }.sort
      else
        []
      end
    end

    def path_ids
      memoized do
        (root_info.path1 - root_info.path2) + (root_info.path2 - root_info.path1)
      end
    end

    def root_info
      memoized do
        Revisions::QueryClosestRoot.run!(
          revision1: revision_left,
          revision2: revision_right,
          raw: true
        ).result
      end
    end
  end
end
