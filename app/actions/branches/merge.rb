module Branches
  class Merge < Action::Base
    attr_accessor :branch, :other_branch

    def execute
      branch.working.grapheme_ids = merge_items.map(&:id)

      if no_conflicts?
        Branches::Commit.run! branch: branch
      else
        branch.working.conflict!
      end

      branch
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
