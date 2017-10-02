module Graphemes
  class QueryMerge < Action::Base
    attr_accessor :branch_left, :branch_right

    validates :branch_left, presence: true
    validates :branch_right, presence: true

    def execute
      non_conflicts.
        union_all(conflicts).
        select("distinct on (id) #{select_columns}")
    end

    def non_conflicts
      not_changed.
        union_all(changed_in_left_not_in_right).
        union_all(changed_in_right_not_in_left).
        union_all(added_in_left).
        union_all(added_in_right).
        select("distinct on (id) #{select_columns}")
    end

    def select_columns
      columns_string = columns_without_status.map { |c| "graphemes.#{c}" }.join ", "
      "#{columns_string}, status"
    end

    def columns_without_status
      Grapheme.columns.map(&:name) - ["status"]
    end

    def conflicts
      root.graphemes.reorder(nil).
        where.not(id: left.graphemes.reorder(nil).select(:id)).
        where.not(id: right.graphemes.reorder(nil).select(:id)).
        select <<-SQL
          distinct on(id) #{columns_without_status.map { |c| "graphemes.#{c}" }.join(", ")},
          #{Grapheme.statuses[:conflict]} as status
        SQL
    end

    def not_changed
      root.graphemes.reorder(nil).
        where(id: left.graphemes.reorder(nil).select(:id)).
        where(id: right.graphemes.reorder(nil).select(:id)).
        select(select_columns)
    end

    def changed_in_left_not_in_right
      left.graphemes.reorder(nil).where(
        "parent_ids && array[(?)]", right.graphemes.reorder(nil).select("array_agg(id)")
      ).
      select(select_columns)
    end

    def changed_in_right_not_in_left
      right.graphemes.reorder(nil).where(
        "parent_ids && array[(?)]", left.graphemes.reorder(nil).select("array_agg(id)")
      ).
      select(select_columns)
    end

    def added_in_left
      left.graphemes.reorder(nil).
        where.not(id: root.graphemes.reorder(nil).select(:id)).
        select(select_columns)
    end

    def added_in_right
      right.graphemes.reorder(nil).
        where.not(id: root.graphemes.reorder(nil).select(:id)).
        select(select_columns)
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
