module Graphemes
  class QueryPage < Action::Base
    attr_accessor :surface, :revision_id, :branch_name, :area

    def execute
      # todo: support the area param, if the need will be

      Grapheme.find_by_sql [ sql, surface.id ]
    end

    def sql
      memoized do
        <<-SQL
          select graphemes.*
          from graphemes
          inner join #{revision.graphemes_revisions_partition_table_name}
            on #{revision.graphemes_revisions_partition_table_name}.grapheme_id = graphemes.id
          inner join zones
            on graphemes.zone_id = zones.id
          where zones.surface_id = ?
        SQL
      end
    end

    def revision
      memoized do
        if revision_id.present?
          Revision.find(revision_id)
        else
          Revision.joins(:branches).
                   where(
                     branches: { name: 'master' },
                     document_id: surface.document_id
          ).first
        end
      end
    end
  end
end
