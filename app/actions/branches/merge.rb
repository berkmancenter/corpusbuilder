module Branches
  class Merge < Action::Base
    attr_accessor :branch, :other_branch

    validate :branches_not_in_conflicts

    def execute
      Revisions::PointAtGraphemes.run! ids: merge_ids,
        target: branch.working

      branch.working.update_attributes!(merged_with_id: other_branch.revision_id)

      if no_conflicts?
        Branches::Commit.run! branch: branch
      else
        branch.working.conflict!
      end

      branch
    end

    def no_conflicts?
      @_no_conflicts ||= merge_conflicts.empty?
    end

    def merge_ids
      @_merge_ids ||= -> {
        to_exclude_ids = self.exclude_ids
        conflict_graphemes.map(&:id).concat(branch_item_ids).
                                     concat(other_branch_ids).
                                     uniq - to_exclude_ids - conflicting_ids - removed_ids
      }.call
    end

    def all_branch_ids(branch)
      Grapheme.connection.
        execute("select grapheme_id from #{branch.revision.graphemes_revisions_partition_table_name}").
        to_a.map { |item| item["grapheme_id"] }
    end

    def branch_item_ids
      @_branch_item_ids ||= -> {
        all_branch_ids(branch)
      }.call
    end

    def other_branch_ids
      @_other_branch_ids ||= -> {
        all_branch_ids(other_branch)
      }.call
    end

    def removed_ids
      @_removed_ids ||= -> {
        branch_removed = branch_diff.select { |g| g.inclusion == 'left' }.
                    reject { |g| other_branch_diff.any? { |g2| g2.area.overlaps?(g.area) } }
        other_branch_removed = other_branch_diff.select { |g| g.inclusion == 'left' }.
                    reject { |g| branch_diff.any? { |g2| g2.area.overlaps?(g.area) } }
        branch_removed.concat(other_branch_removed).map(&:id)
      }.call
    end

    def conflicting_ids
      @_conflicting_ids ||= merge_conflicts.map { |c| [c.grapheme.id, c.with.id] }.flatten
    end

    def conflict_graphemes
      @_conflict_graphemes || -> {
        theirs = merge_conflicts.reject(&:ours).select { |g| g.grapheme.inclusion == 'right' }
        ours   = merge_conflicts.select(&:ours).select { |g| g.grapheme.inclusion == 'right' }

        (theirs + ours).map do |conflict|
          Grapheme.create! conflict.grapheme.attributes.without("id", "inclusion", "surface_number").
                                                        merge("status" => Grapheme.statuses[:conflict])
        end
      }.call
    end

    def branch_diff
      @_branch_diff ||= Graphemes::QueryDiff.run(
        revision_left: root,
        revision_right: branch.revision
      ).result.uniq
    end

    def other_branch_diff
      @_other_branch_diff ||= Graphemes::QueryDiff.run(
        revision_left: root,
        revision_right: other_branch.revision
      ).result.uniq
    end

    def root
      @_root ||= Revisions::QueryClosestRoot.run!(
        revision1: branch.revision,
        revision2: other_branch.revision
      ).result
    end

    def merge_conflicts
      @_merge_conflicts ||= branch_merge_conflicts.
        concat(other_branch_merge_conflicts).
        select { |c| c.with.present? }
    end

    def other_branch_merge_conflicts
      @_other_branch_merge_conflicts ||= -> {
        other_branch_diff.select { |g| g.inclusion == 'right' }.map do |g1|
          with = branch_diff.select do |g2|
            g1.area.overlaps?(g2.area)
          end.reject do |g2|
            branch_merge_conflicts.any? { |c| g2.area.overlaps?(c.grapheme.area) }
          end.first

          Conflict.new(g1, with, true)
        end
      }.call
    end

    def branch_merge_conflicts
      @_branch_merge_conflicts ||= -> {
        branch_diff.select { |g| g.inclusion == 'right' }.map do |g1|
          Conflict.new(g1, other_branch_diff.find { |g2| g1.area.overlaps?(g2.area) }, false)
        end
      }.call
    end

    def exclude_ids
      @_exclude_ids ||= Graphemes::QueryMergeExcludes.run!(
        branch_left: branch,
        branch_right: other_branch
      ).result
    end

    def branches_not_in_conflicts
      if branch.conflict?
        errors.add(:branch, "cannot be in an unresolved conflict state")
      end

      if other_branch.conflict?
        errors.add(:other_branch, "cannot be in an unresolved conflict state")
      end
    end

    def create_development_dumps?
      true
    end

    class Conflict
      attr_accessor :grapheme, :with, :ours

      def initialize(grapheme, with, ours)
        @grapheme = grapheme
        @with = with
        @ours = ours
      end
    end
  end
end
