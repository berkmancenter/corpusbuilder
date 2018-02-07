module Annotations
  class QueryDiff < Action::Base
    attr_accessor :revision_left, :revision_right, :reject_mirrored

    validates :revision_right, presence: true

    def execute
      if reject_mirrored == true
        all_diffs.reject { |g| has_mirrored?(g) }
      else
        all_diffs
      end
    end

    def all_diffs
      @_all_diffs ||= -> {
        sql = <<-sql
          select g.annotation_id as id,
                 g.inclusion[1],
                 g.revision_ids[1] as revision_id,
                 annotations.mode,
                 annotations.content,
                 annotations.payload,
                 annotations.areas
          from (
            select gs.annotation_id,
                   array_agg(gs.inclusion) as inclusion,
                   array_agg(gs.revision_id) as revision_ids
            from (
              select annotation_id, 'left' as inclusion, revision_id
              from annotations_revisions
              where revision_id = '#{revision_left.id}'
              union all
              select annotation_id, 'right' as inclusion, revision_id
              from annotations_revisions
              where revision_id = '#{revision_right.id}'
            ) gs
            group by annotation_id
            having array_length(array_agg(gs.inclusion), 1) < 2
          ) g
          inner join annotations
                  on annotations.id = g.annotation_id
          order by annotations.surface_number
        sql

        Annotation.find_by_sql sql
      }.call
    end

    def has_mirrored?(annotation)
      all_diffs.any? do |other|
        annotation.inclusion != other.inclusion &&
          annotation.mode == other.mode &&
          annotation.areas == other.areas &&
          annotation.content == other.content &&
          annotation.payload == other.payload
      end
    end
  end
end

