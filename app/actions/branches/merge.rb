module Branches
  class Merge < Action::Base
    attr_accessor :branch, :other_branch

    def execute
      if no_conflicts?
        branch.working.grapheme_ids = merge_items.map(&:id)
        Branches::Commit.run! branch: branch
      else
      end
    end

    def no_conflicts?
      @_no_conflicts ||= merge_items.none?(&:conflict?)
    end

    def merge_items
      @_merge_items ||= Graphemes::QueryMerge.run!(
        branch_left: branch,
        branch_right: other_branch
      ).result
    end
  end
end
