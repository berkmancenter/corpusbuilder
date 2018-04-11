module Documents
  class Correct < Action::Base
    attr_accessor :document, :graphemes, :branch_name, :editor_id, :surface_number, :revision_id

    validates :document, presence: true
    validates :editor_id, presence: true
    validates :surface_number, presence: true
    validate :revision_is_in_working_state
    validate :branch_for_working_revision_exists
    validate :branch_is_not_locked

    def execute
      @graphemes.each do |spec|
        if spec.fetch(:delete, false)
         Revisions::RemoveGrapheme.run!(
           revision_id: revision.id,
           grapheme_id: spec[:id]
         )
        else
          raise ArgumentError, "Missing position_weight in correction spec!" if spec[:position_weight].nil?

          grapheme = Graphemes::Create.run!(
            revision: revision,
            area: area(spec),
            certainty: 1,
            value: spec[:value],
            given_zone_id: spec[:zone_id],
            old_id: spec[:id],
            position_weight: spec[:position_weight],
            surface_number: spec[:surface_number]
          ).result
          log_correction(grapheme.id, revision.id, :addition)
        end
      end

      existing_ids.each do |grapheme_id|
        Revisions::RemoveGrapheme.run!(
          revision_id: revision.id,
          grapheme_id: grapheme_id
        )
        log_correction(grapheme_id, revision.id, :removal)
      end

      if revision.conflict? && revision.conflict_graphemes.count == 0
        revision.update_attributes!(
          status: Revision.statuses[:working]
        )
      end

      @graphemes
    end

    def area(spec)
      if spec.has_key? :area
        if spec[:area].is_a? Area
          spec[:area]
        else
          Area.new(ulx: spec[:area][:ulx],
                  uly: spec[:area][:uly],
                  lrx: spec[:area][:lrx],
                  lry: spec[:area][:lry])
        end
      else
        if spec.has_key? :id
          Grapheme.find(spec[:id]).area
        else
          raise ArgumentError, "You either need to specify an area or an id of existing grapheme"
        end
      end
    end

    def log_correction(grapheme_id, revision_id, status)
      CorrectionLog.create! grapheme_id: grapheme_id,
        revision_id: revision_id,
        editor_id: editor_id,
        surface_number: surface_number,
        status: status
    end

    def existing_ids
      @graphemes.map { |g| g.fetch(:id, nil) }.reject(&:nil?).uniq
    end

    def revision
      memoized do
        if revision_id.present?
          Revision.find(revision_id)
        else
          Revision.working.where(
              parent_id: @document.branches.where(name: @branch_name).select("branches.revision_id")
          ).first
        end
      end
    end

    def branch
      memoized do
        @document.branches.
          where(revision_id: revision.parent_id).
          first
      end
    end

    def revision_is_in_working_state
      if !revision.working?
        if revision_id.present?
          errors.add(:revision_id, "must point at an uncommitted revision")
        else
          if branch_name.present?
            error.add(:branch_name, "points at a branch with inconsistent state, having a working revision not set to a working state")
          end
        end
      end
    end

    def branch_for_working_revision_exists
      if !branch.present?
        if revision_id.present?
          errors.add(:revision_id, "must point at a working revision of existing branch")
        else
          if branch_name.present?
            error.add(:branch_name, "must point at an existing branch inside a document")
          end
        end
      end
    end

    def branch_is_not_locked
      if branch.locked?
        errors.add(:base, "another operation is taking place on a branch, please try again later")
      end
    end

    def create_development_dumps?
      true
    end
  end
end
