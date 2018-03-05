module Branches
  class Merge < Action::Base
    attr_accessor :branch, :other_branch, :current_editor_id

    validates :branch, presence: true
    validates :other_branch, presence: true
    validates :current_editor_id, presence: true
    validate :branches_not_in_conflicts
    validate :working_is_clean

    def execute
      #Revisions::PointAtGraphemes.run! ids: merge_ids,
      #  target: branch.working

      Revisions::AddGraphemes.run!(
        revision_id: branch.working.id,
        grapheme_ids: (
          added_ids + conflict_graphemes.map(&:id)
        )
      )

      Revisions::RemoveGraphemes.run!(
        revision_id: branch.working.id,
        grapheme_ids: (
          exclude_ids + removed_ids + conflicting_ids
        )
      )

      branch.working.update_attributes!(merged_with_id: other_branch.revision_id)

      Annotations::Merge.run!(
        revision: branch.revision,
        other_revision: other_branch.revision,
        current_editor_id: current_editor_id
      )

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
        self.exclude_ids
        branch_item_ids
        other_branch_ids
        removed_ids
        conflicting_ids

        time "calculating merge_ids in Branches::Merge" do
          to_exclude_ids = self.exclude_ids

          conflict_graphemes.map(&:id).concat(branch_item_ids).
                                      concat(other_branch_ids).
                                      uniq - to_exclude_ids - removed_ids - conflicting_ids
        end
      }.call
    end

    def added_ids
      memoized do
        # all ids added by the other branch
        other_branch_changes.reject(&:removal?).map(&:to).map(&:id)
      end
    end

    def all_branch_ids(branch)
      Grapheme.connection.
        execute("select grapheme_id from #{branch.revision.graphemes_revisions_partition_table_name}").
        to_a.map { |item| item["grapheme_id"] }
    end

    def branch_item_ids
      memoized do
        time "calculating branch_item_ids in Branches::Merge" do
          all_branch_ids(branch)
        end
      end
    end

    def other_branch_ids
      memoized do
        time "calculating other_branch_ids in Branches::Merge" do
          all_branch_ids(other_branch)
        end
      end
    end

    def conflicting_ids
      @_conflicting_ids ||= merge_conflicts.map(&:ids).flatten
    end

    def removed_ids
      memoized do
        time "calculating removed_ids in Branches::Merge" do
          branch_changes.concat(other_branch_changes).select(&:removal?).select do |change|
            merge_conflicts.none? { |conflict| conflict.includes?(change) }
          end.map(&:from).map(&:id).uniq
        end
      end
    end

    def conflict_graphemes
      @_conflict_graphemes ||= -> {
        merge_conflicts.map do |conflict|
          Grapheme.create! conflict.output_grapheme.
            attributes.
            without("id", "inclusion", "revision_id", "surface_number", "status").
            merge("status" => Grapheme.statuses[:conflict])
        end
      }.call
    end

    def branch_diff
      @_branch_diff ||= Graphemes::QueryDiff.run(
        revision_left: root,
        revision_right: branch.revision,
        reject_mirrored: true
      ).result.uniq
    end

    def branch_changes
      @_branch_changes ||= compile_changes(branch_diff)
    end

    def other_branch_changes
      @_other_branch_changes ||= compile_changes(other_branch_diff)
    end

    def compile_changes(diffs)
      results = []

      roots = Set.new(diffs.select { |g| g.inclusion == 'left' })
      rights = Set.new(diffs.select { |g| g.inclusion == 'right' })

      roots.each do |root_grapheme|
        found = root_grapheme.special? ? nil : rights.find do |g|
          !g.special? && g.area.overlaps?(root_grapheme.area)
        end

        results.push(
          Change.new(root_grapheme, found)
        )

        if found.present?
          rights.delete(found)
        end

        roots.delete(root_grapheme)
      end

      rights.each do |right|
        results.push(Change.new(nil, right))
      end

      rights.clear

      results
    end

    def other_branch_diff
      @_other_branch_diff ||= Graphemes::QueryDiff.run(
        revision_left: root,
        revision_right: other_branch.revision,
        reject_mirrored: true
      ).result.uniq
    end

    def root
      @_root ||= Revisions::QueryClosestRoot.run!(
        revision1: branch.revision,
        revision2: other_branch.revision
      ).result
    end

    def merge_conflicts
      memoized do
        time "calculating merge_conflicts in Branches::Merge" do
          branch_changes.map do |our_change|
            found = other_branch_changes.find do |other_change|
              our_change.area.overlaps? other_change.area
            end

            found.present? ? [ our_change, found ] : nil
          end.reject(&:nil?).map do |our_change, their_change|
            Conflict.new(our_change, their_change)
          end.reject(&:both_remove?)
        end
      end
    end

    def exclude_ids
      memoized do
        Graphemes::QueryMergeExcludes.run!(
          branch_left: branch,
          branch_right: other_branch
        ).result
      end
    end

    def working_changes
      memoized do
        Graphemes::QueryDiff.run(
          revision_left: branch.working,
          revision_right: branch.revision,
          reject_mirrored: true
        ).result.uniq
      end
    end

    def working_is_clean
      if working_changes.present?
        errors.add(:base, "cannot merge with a branch that has uncommitted changed in the working version")
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

    def create_development_dumps?
      true
    end

    class Change
      attr_accessor :from, :to

      def initialize(from, to)
        @from = from
        @to = to
      end

      def area
        from.try(:area) || to.try(:area)
      end

      def removal?
        to.nil?
      end

      def addition?
        from.nil?
      end

      def inspect
        "#{from.present? ? from.value : '∅'} --> #{to.present? ? to.value : '∅'}"
      end
    end

    class Conflict
      attr_accessor :our_change, :their_change

      def initialize(our_change, their_change)
        @our_change = our_change
        @their_change = their_change
      end

      def includes?(change)
        our_change == change || their_change == change
      end

      def both_remove?
        our_change.removal? && their_change.removal?
      end

      def output_grapheme
        their_change.to || our_change.to || our_change.from
      end

      def ids
        [ our_change.to.try(:id), their_change.to.try(:id) ].reject(&:nil?)
      end

      def inspect
        "<Conflict our={ #{our_change.inspect} } their={ #{their_change.inspect} }>"
      end
    end
  end
end
