module Documents
  class QuerySimilar < Action::Base
    attr_accessor :app, :status, :metadata

    def execute
      Document.find_by_sql sql
    end

    def sql
      sql_query = <<-SQL
        with documents_index as (
          select id,
                 to_tsvector(title || coalesce(date :: varchar, '') || coalesce(authority :: varchar, '') || coalesce(editor :: varchar, '') || coalesce(license :: varchar, '') || coalesce(notes :: varchar, '') || coalesce(publisher :: varchar, '')) as index_vector
          from documents
        )
        select *
        from documents
        inner join documents_index
                on documents_index.id = documents.id
        where status = ?
          and app_id = ?
          and documents_index.index_vector @@ to_tsquery(?)
        order by ts_rank(documents_index.index_vector, to_tsquery(?))
      SQL

      [ sql_query, status, app.id, query, query ]
    end

    def query
      memoized do
        PragmaticTokenizer::Tokenizer.new(downcase: true, punctuation: :none).
          tokenize(combined_phrase).
          join(' | ')
      end
    end

    def combined_phrase
      [
        metadata[:title],
        metadata[:date],
        metadata[:editor],
        metadata[:license],
        metadata[:notes],
        metadata[:publisher]
      ].join(' ')
    end
  end
end

