module Branches
  class Merge < Action::Base
    attr_accessor :branch, :other_branch

    validate :branches_not_in_conflicts

    def execute
      #branch.working.grapheme_ids = merge_items.map(&:id)
      Revisions::PointAtGraphemes.run! ids: merge_items.map(&:id),
        target: branch.working

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
      ).result.map do |grapheme|
        if grapheme.conflict?
          grapheme = Grapheme.create! grapheme.attributes.without("id")
        end

        grapheme
      end
    end

    def branches_not_in_conflicts
      if branch.conflict?
        errors.add(:branch, "cannot be in an unresolved conflict state")
      end

      if other_branch.conflict?
        errors.add(:other_branch, "cannot be in an unresolved conflict state")
      end
    end
  end
end
