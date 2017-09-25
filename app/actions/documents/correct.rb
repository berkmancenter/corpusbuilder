module Documents
  class Correct < Action::Base
    attr_accessor :document, :graphemes, :revision_id, :branch_name

    validate :revision_is_in_working_state

    def execute
      @graphemes.each do |spec|
        if spec.fetch(:delete, false)
          Graphemes::Remove.run! revision: revision,
            grapheme_id: spec[:id]
        else
          Graphemes::Create.run! revision: revision,
            area: area(spec),
            value: spec[:value],
            old_id: spec[:id],
            surface_number: spec[:surface_number]
        end
      end

      revision.grapheme_ids = revision.grapheme_ids - existing_ids
    end

    private

    def area(spec)
      if spec.has_key? :area
      Area.new(ulx: spec[:area][:ulx],
               uly: spec[:area][:uly],
               lrx: spec[:area][:lrx],
               lry: spec[:area][:lry])
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
      @_revision ||= if @revision_id.present?
        Revision.find(@revision_id)
      else
        Revision.working.where(
          parent_id: @document.branches.where(name: @branch_name).select("branches.revision_id")
        ).first
      end
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
  end
end
