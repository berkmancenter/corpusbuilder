module Annotations
  class QueryCategories < Action::Base
    attr_accessor :document

    def execute
      categories.map(&:name)
    end

    def categories
      memoized do
        query = <<-SQL
          select distinct categories.* :: varchar as name
          from (
            select annotations.*
            from annotations
            inner join annotations_revisions on annotations_revisions.annotation_id = annotations.id
            inner join revisions on revisions.id = annotations_revisions.revision_id
            inner join branches on revisions.id = branches.revision_id
            where revisions.document_id = '#{ document.id }'
          ) annotations, json_array_elements_text(annotations.payload->'categories') categories
        SQL

        Annotation.find_by_sql query
      end
    end
  end
end
