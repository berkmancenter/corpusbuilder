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
      Grapheme.where(value: '').unscoped
    end

    def not_changed
      ancestor.graphemes.unscoped.
        where(id: left.graphemes.unscoped.select(:id)).
        where(id: right.graphemes.unscoped.select(:id))
    end

    def changed_in_left_not_in_right
      left.graphemes.unscoped.where(
        "parent_ids && array[(?)]", right.graphemes.unscoped.select("array_agg(id)")
      )
    end

    def changed_in_right_not_in_left
      right.graphemes.unscoped.where(
        "parent_ids && array[(?)]", left.graphemes.unscoped.select("array_agg(id)")
      )
    end

    def added_in_left
      left.graphemes.unscoped.where.not(id: ancestor.graphemes.unscoped.select(:id))
    end

    def added_in_right
      right.graphemes.unscoped.where.not(id: ancestor.graphemes.unscoped.select(:id))
    end

    private

    def ancestor
      # todo: correct the following:
      branch_left.revision
    end

    def left
      branch_left.revision
    end

    def right
      branch_right.revision
    end
  end
end
