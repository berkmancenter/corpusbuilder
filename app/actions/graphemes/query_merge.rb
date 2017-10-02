module Graphemes
  class QueryMerge < Action::Base
    attr_accessor :branch_left, :branch_right

    validates :branch_left, presence: true
    validates :branch_right, presence: true

    def execute
      non_conflicts.
        union_all(conflicts).
        select("distinct on (id) graphemes.*")
    end

    def non_conflicts
      not_changed.
        union_all(changed_in_left_not_in_right).
        union_all(changed_in_right_not_in_left).
        union_all(added_in_left).
        union_all(added_in_right).
        select("distinct on (id) graphemes.*")
    end

    def conflicts
      Grapheme.reorder(nil).where(value: '')
    end

    def not_changed
      root.graphemes.reorder(nil).
        where(id: left.graphemes.reorder(nil).select(:id)).
        where(id: right.graphemes.reorder(nil).select(:id))
    end

    def changed_in_left_not_in_right
      left.graphemes.reorder(nil).where(
        "parent_ids && array[(?)]", right.graphemes.reorder(nil).select("array_agg(id)")
      )
    end

    def changed_in_right_not_in_left
      right.graphemes.reorder(nil).where(
        "parent_ids && array[(?)]", left.graphemes.reorder(nil).select("array_agg(id)")
      )
    end

    def added_in_left
      left.graphemes.reorder(nil).where.not(id: root.graphemes.reorder(nil).select(:id))
    end

    def added_in_right
      right.graphemes.reorder(nil).where.not(id: root.graphemes.reorder(nil).select(:id))
    end

    private

    def root
      @_root ||= Revisions::QueryClosestRoot.run!(
        revision1: left,
        revision2: right
      ).result
    end

    def left
      branch_left.revision
    end

    def right
      branch_right.revision
    end
  end
end
