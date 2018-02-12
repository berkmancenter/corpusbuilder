module Annotations

  # A ruby-land implementation since we won't have as many annotations
  class Merge < Action::Base
    attr_accessor :revision, :other_revision, :current_editor_id

    def execute
      revision.annotations = merged_annotations.flatten
    end

    def merged_annotations
      @_merged_annotations ||= all -
        conflicts.map(&:items).flatten +
        conflicts.map(&:to_merged) -
        duplicates
    end

    def all
      @_all ||= ours.values.flatten + theirs.values.flatten
    end

    def surface_numbers
      @_surface_numbers ||= (ours.keys + theirs.keys).uniq
    end

    def conflicts
      # as per the 09.02.2018 call - we're ignoring the conflicts
      # and just concatenate all annotations / tags
      # the code that follows is left here for future decisions
      @_conflicts ||= [ ] || -> {
        result = []

        surface_numbers.each do |surface_number|
          ours_structural = Set.new(
            (ours[ surface_number ] || []).select(&:structural?)
          )
          theirs_structural = Set.new(
            (theirs[ surface_number ] || []).select(&:structural?)
          )

          ours_structural.each do |our|
            theirs_structural.each do |their|
              if conflict?(our, their)
                ours_structural.delete(our)
                theirs_structural.delete(their)

                result << Conflict.new(our, their, current_editor_id)
              end
            end
          end
        end

        result.flatten
      }.call
    end

    def duplicates
      @_duplicates ||= -> {
        result = [ ]

        surface_numbers.each do |surface_number|
          ours_set = Set.new(ours[ surface_number ])
          theirs_set = Set.new(theirs[ surface_number ])

          ours_set.each do |our|
            theirs_set.each do |their|
              if our.mode == their.mode &&
                  our.areas.all? { |a1| their.areas.all? { |a2| a1 == a2 } } &&
                  our.payload == their.payload &&
                  our.content == their.content
                ours_set.delete(our)
                theirs_set.delete(their)

                result << their
              end
            end
          end
        end

        result.flatten
      }.call
    end

    def ours
      @_ours ||= revision.annotations.group_by(&:surface_number)
    end

    def theirs
      @_theirs ||= other_revision.annotations.group_by(&:surface_number)
    end

    def conflict?(left, right)
      # all structural that overlap in any area
      # and have the same mode but have either areas not exactly
      # the same or the payload or content is different

        left.structural? &&
        left.overlaps?(right) &&
        (
          left.areas.any? { |a1| right.areas.any? { |a2| a1 != a2 } } ||
          left.payload != right.payload ||
          left.content != right.content ||
          left.mode != right.mode
        )
    end

    def create_development_dumps?
      true
    end

    class Conflict
      attr_accessor :left, :right, :current_editor_id

      def initialize(left, right, current_editor_id)
        @left = left
        @right = right
        @current_editor_id = current_editor_id
      end

      def to_merged
        @_to_merged ||= Annotation.create! content: right.content,
          editor_id: current_editor_id,
          areas: right.areas,
          surface_number: right.surface_number,
          mode: right.mode,
          payload: right.payload,
          status: Annotation.statuses[:conflict]
      end

      def items
        [ left, right ]
      end
    end
  end
end
