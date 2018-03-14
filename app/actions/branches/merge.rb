module Branches
  class Merge < Action::Base
    attr_accessor :branch, :other_branch, :current_editor_id

    validates :branch, presence: true
    validates :other_branch, presence: true
    validates :current_editor_id, presence: true
    validate :branches_not_in_conflicts
    validate :working_is_clean

    def execute
      Revisions::AddGraphemes.run!(
        revision_id: branch.working.id,
        grapheme_ids: (
          added_ids + conflict_graphemes.map(&:id)
        )
      )

      conflict_graphemes.each do |conflict|
        CorrectionLog.create! grapheme: conflict,
          revision: branch.working,
          editor_id: current_editor_id,
          status: CorrectionLog.statuses[:merge_conflict]
      end

      Revisions::RemoveGraphemes.run!(
        revision_id: branch.working.id,
        grapheme_ids: (
          removed_ids + conflicting_ids
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
      merge_conflicts.empty?
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
      memoized do
        merge_conflicts.map(&:ids).flatten
      end
    end

    def removed_ids
      memoized do
        time "calculating removed_ids in Branches::Merge" do
          branch_changes.select(&:removal?).
            concat(other_branch_changes.select(&:removal?)).
            map(&:from).map(&:id).uniq

         # branch_changes.concat(other_branch_changes).select(&:removal?).select do |change|
         #   merge_conflicts.none? { |conflict| conflict.includes?(change) }
         # end.map(&:from).map(&:id).uniq
        end
      end
    end

    def conflict_graphemes
      memoized do
        merge_conflicts.map do |conflict|
          Grapheme.create! conflict.output_grapheme.
            attributes.
            without("id", "inclusion", "revision_id", "surface_number", "status").
            merge("status" => Grapheme.statuses[:conflict])
        end
      end
    end

    def branch_diff
      memoized do
        Graphemes::QueryDiff.run(
          revision_left: root,
          revision_right: branch.revision,
          reject_mirrored: true
        ).result.uniq
      end
    end

    def branch_changes
      memoized do
        compile_changes(branch_diff)
      end
    end

    def other_branch_changes
      memoized do
        compile_changes(other_branch_diff)
      end
    end

    def compile_changes(diffs)
      results = []

      roots = Set.new(diffs.select { |g| g.inclusion == 'left' })
      rights = Set.new(diffs.select { |g| g.inclusion == 'right' })

      roots.each do |root_grapheme|
        found = root_grapheme.special? ? nil : rights.find do |g|
          !g.special? && root_grapheme.surface_number == g.surface_number &&
            g.area.overlaps?(root_grapheme.area)
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
      memoized do
        Graphemes::QueryDiff.run(
          revision_left: root,
          revision_right: other_branch.revision,
          reject_mirrored: true
        ).result.uniq
      end
    end

    def root
      memoized do
        Revisions::QueryClosestRoot.run!(
          revision1: branch.revision,
          revision2: other_branch.revision
        ).result
      end
    end

    def merge_conflicts
      memoized do
        time "calculating merge_conflicts in Branches::Merge" do
          return [] if branch_changes.empty? || other_branch_changes.empty?

          ours_ix = 0
          theirs_ix = 0

          conflicts = []
          ours = Set.new
          theirs = Set.new
          surface_number = branch_changes.first.surface_number

          loop do
            loop do
              next_ours = branch_changes[ ours_ix ]

              if next_ours.try(:surface_number) != surface_number
                break
              else
                ours.add(next_ours)
                ours_ix += 1
              end
            end

            loop do
              next_theirs = other_branch_changes[ theirs_ix ]

              if next_theirs.nil?
                break
              elsif next_theirs.surface_number < surface_number
                theirs_ix += 1
              elsif next_theirs.surface_number != surface_number
                break
              else
                theirs.add(next_theirs)
                theirs_ix += 1
              end
            end

            conflicts += ours.map do |our_change|
              found = theirs.find do |other_change|
                our_change.area.overlaps?(other_change.area)
              end

              if found.present?
                theirs.delete(found)

                [ our_change, found ]
              else
                nil
              end

              found.present? ? [ our_change, found ] : nil
            end.reject(&:nil?).map do |our_change, their_change|
              Conflict.new(our_change, their_change)
            end.reject(&:both_remove?)

            ours.clear
            theirs.clear
            surface_number = branch_changes[ ours_ix ].try(:surface_number)

            if ours_ix >= branch_changes.count || theirs_ix >= other_branch_changes.count
              break
            end
          end

          conflicts
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

      def surface_number
        from.try(:surface_number) || to.try(:surface_number)
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
