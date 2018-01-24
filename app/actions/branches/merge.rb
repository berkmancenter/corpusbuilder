require 'benchmark'

module Branches
  class Merge < Action::Base
    attr_accessor :branch, :other_branch

    validate :branches_not_in_conflicts

    def execute
      took = Benchmark.measure do
        Revisions::PointAtGraphemes.run! ids: merge_ids,
          target: branch.working
      end

      Rails.logger.debug "Merge benchmark took: #{took}"

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
                                     uniq - to_exclude_ids - conflicting_ids
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

    def conflicting_ids
      @_conflicting_ids ||= merge_conflicts.map(&:conflicting_ids).flatten
    end

    def conflict_graphemes
      @_conflict_graphemes ||= -> {
        ours_conflicts = merge_conflicts.uniq.select { |g| g.revision_id == other_branch.revision_id }
        root_conflicts = merge_conflicts.uniq.
          select { |g| g.revision_id != other_branch.revision_id }.
          reject { |g1| ours_conflicts.any? { |g2| g1.area.overlaps?(g2.area) } }
       (ours_conflicts + root_conflicts).map do |grapheme|
         Grapheme.create! grapheme.attributes.without("id", "conflicting_ids", "surface_number", "inclusion", "revision_id").
                                              merge("status" => Grapheme.statuses[:conflict])
       end
      }.call
    end

    def merge_conflicts
      @_merge_conflicts ||= Graphemes::QueryMergeConflicts.run!(
        branch_left: branch,
        branch_right: other_branch
      ).result
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
  end
end
