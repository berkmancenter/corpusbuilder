module Documents
  class Correct < Action::Base
    attr_accessor :document, :graphemes, :branch_name

    # validate :revision_is_in_working_state

    def execute
      @graphemes.each do |spec|
        if spec.fetch(:delete, false)
         Revisions::RemoveGrapheme.run!(
           revision_id: revision.id,
           grapheme_id: spec[:id]
         )
        else
          Graphemes::Create.run!(
            revision: revision,
            area: area(spec),
            certainty: 1,
            value: spec[:value],
            old_id: spec[:id],
            position_weight: spec[:position_weight],
            surface_number: spec[:surface_number]
          )
        end
      end

      existing_ids.each do |grapheme_id|
        Revisions::RemoveGrapheme.run!(
          revision_id: revision.id,
          grapheme_id: grapheme_id
        )
      end

      if revision.conflict? && revision.graphemes.where(status: Grapheme.statuses[:conflict]).count == 0
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

    def existing_ids
      @graphemes.map { |g| g.fetch(:id, nil) }.reject(&:nil?).uniq
    end

    def revision
      @_revision ||= Revision.working.where(
          parent_id: @document.branches.where(name: @branch_name).select("branches.revision_id")
      ).first
    end

    def revision_is_in_working_state
      if !revision.working?
        if revision_id.present?
          errors.add(:revision_id, "must point at an uncommitted revision")
        end

        if branch_name.present?
          error.add(:branch_name, "points at a branch with inconsistent state, having a working revision not set to a working state")
        end
      end
    end

    def create_development_dumps?
      true
    end
  end
end
