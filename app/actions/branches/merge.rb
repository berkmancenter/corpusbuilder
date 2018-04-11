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
          added_ids + conflict_graphemes.map(&:last).map(&:id)
        )
      )

      conflict_graphemes.each do |pair|
        surface_number, conflict = pair

        CorrectionLog.create! grapheme: conflict,
          revision: branch.working,
          editor_id: current_editor_id,
          surface_number: surface_number,
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
    ensure
      branch.regular!
    end

    def no_conflicts?
      merge_conflicts.empty?
    end

    def added_ids
      memoized freeze: true do
        # all ids added by the other branch
        other_branch_changes.reject(&:removal?).map(&:to).map(&:id) - duplicates.map(&:id)
      end
    end

    def all_branch_ids(branch)
      Grapheme.connection.
        execute("select grapheme_id from #{branch.revision.graphemes_revisions_partition_table_name}").
        to_a.map { |item| item["grapheme_id"] }
    end

    def branch_item_ids
      memoized freeze: true do
        time "calculating branch_item_ids in Branches::Merge" do
          all_branch_ids(branch)
        end
      end
    end

    def other_branch_ids
      memoized freeze: true do
        time "calculating other_branch_ids in Branches::Merge" do
          all_branch_ids(other_branch)
        end
      end
    end

    def conflicting_ids
      memoized freeze: true do
        merge_conflicts.map(&:ids).flatten
      end
    end

    def removed_ids
      memoized freeze: true do
        time "calculating removed_ids in Branches::Merge" do
          (branch_changes + other_branch_changes).
            map(&:from).reject(&:nil?).map(&:id).uniq
        end
      end
    end

    def conflict_graphemes
      memoized freeze: true do
        merge_conflicts.map do |conflict|
          [
            conflict.output_grapheme.surface_number,
            Grapheme.create!(
              conflict.output_grapheme.
              attributes.
              without("id", "inclusion", "revision_id", "surface_number", "status").
              merge("status" => Grapheme.statuses[:conflict], "parent_ids" => conflict.ids)
            )
          ]
        end
      end
    end

    def branch_diff
      memoized freeze: true do
        Graphemes::QueryDiff.run(
          revision_left: root,
          revision_right: branch.revision,
          reject_mirrored: true
        ).result.uniq
      end
    end

    def branch_changes
      memoized freeze: true do
        compile_changes(branch_diff)
      end
    end

    def other_branch_changes
      memoized freeze: true do
        compile_changes(other_branch_diff)
      end
    end

    # TODO: the following common abstraction over the iteration
    # over graphemes grouped by the surface number should get factored
    # out into its own Enumerable
    def compile_changes(diffs)
      results = []

      roots = diffs.select { |g| g.inclusion == 'left' }
      rights = diffs.select { |g| g.inclusion == 'right' }

      if roots.empty? || rights.empty?
        return [ ]
      end

      ours_ix = 0
      theirs_ix = 0

      ours = Set.new
      theirs = Set.new
      surface_number = roots.first.surface_number

      loop do
        loop do
          next_ours = roots[ ours_ix ]

          if next_ours.try(:surface_number) != surface_number
            break
          else
            ours.add(next_ours)
            ours_ix += 1
          end
        end

        loop do
          next_theirs = rights[ theirs_ix ]

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

        results += ours.map do |our_change|
          found = theirs.find do |other_change|
            our_change.area.overlaps?(other_change.area)
          end

          if found.present?
            theirs.delete(found)
          end

          ours.delete(our_change)

          Change.new(our_change, found)
        end.reject(&:nil?)

        ours.each do |g|
          results << Change.new(g, nil)
        end

        theirs.each do |g|
          results << Change.new(nil, g)
        end

        ours.clear
        theirs.clear

        surface_number = roots[ ours_ix ].try(:surface_number)

        if ours_ix >= roots.count || theirs_ix >= rights.count
          break
        end
      end

      results
    end

    def other_branch_diff
      memoized freeze: true do
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

    def duplicates
      memoized freeze: true do
        time "calculating duplicates in Branches::Merge" do
          if branch_changes.empty? || other_branch_changes.empty?
            []
          else
            ours_ix = 0
            theirs_ix = 0

            dups = []
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

              dups += ours.map do |our_change|
                found = theirs.select do |other_change|
                  our_change.to.present? && other_change.to.present? &&
                    our_change.to.area == other_change.to.area &&
                    our_change.to.value == other_change.to.value &&
                    our_change.to.position_weight == other_change.to.position_weight
                end

                if found.present?
                  found.each { |g| theirs.delete(g) }
                else
                  nil
                end

                found.present? ? found : nil
              end.reject(&:nil?).flatten

              ours.clear
              theirs.clear
              surface_number = branch_changes[ ours_ix ].try(:surface_number)

              if ours_ix >= branch_changes.count || theirs_ix >= other_branch_changes.count
                break
              end
            end

            dups.map(&:to)
          end
        end
      end
    end

    def merge_conflicts
      memoized freeze: true do
        time "calculating merge_conflicts in Branches::Merge" do
          if branch_changes.empty? || other_branch_changes.empty?
            []
          else
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
                  our_change.area.overlaps?(other_change.area) &&
                    (
                      !(our_change.to.present? && other_change.to.present?) ||
                      our_change.to.try(:area) != other_change.to.try(:area) ||
                      our_change.to.try(:value) != other_change.to.try(:value) ||
                      our_change.to.try(:position_weight) != other_change.to.try(:position_weight)
                    )
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
    end

    def exclude_ids
      memoized freeze: true do
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
