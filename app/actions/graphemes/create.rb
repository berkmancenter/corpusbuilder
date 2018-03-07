module Graphemes
  class Create < Action::Base
    attr_accessor :revision, :area, :value, :surface_number, :old_id, :position_weight, :certainty,
      :given_zone_id

    validates :revision, presence: true
    validates :value, presence: true
    validates :area, presence: true
    validate :surface_id_inferred

    def execute
      Revisions::AddGrapheme.run!(
        revision_id: revision.id,
        grapheme_id: grapheme.id
      )

      grapheme
    end

    private

    def grapheme
      @_grapheme ||= Grapheme.create!(
        area: area,
        certainty: certainty,
        value: value,
        zone_id: zone_id,
        parent_ids: parent_ids,
        position_weight: position_weight
      )
    end

    def zone_id
      @_zone_id ||= (given_zone_id || existing_zone_id || new_zone_id)
    end

    def parent_ids
      @_parent_ids ||= if parent.present?
        parent.parent_ids + [ old_id ]
      else
        []
      end
    end

    def parent
      return nil if old_id.nil?

      @_parent ||= Grapheme.find(old_id)
    end

    def existing_zone_id
      Zone.where("area @> ?", @area.to_s).
           where(surface_id: surface_id).
           take(1).
           pluck(:id).
           first
    end

    def new_zone_id
      Zone.create!(
        area: area,
        surface_id: surface_id
      ).id
    end

    def surface_id
      @_surface_id ||= (surface_id_by_number || surface_id_by_grapheme_id)
    end

    def surface_id_by_number
      Surface.where(document_id: @revision.document_id).
              where(number: @surface_number).
              pluck(:id).
              first
    end

    def surface_id_by_grapheme_id
      Surface.joins(:graphemes).
        where(graphemes: { id: @old_id }).
        pluck("surfaces.id").
        first
    end

    def surface_id_inferred
      if surface_id.empty?
        errors.add(:base, "needs either surface_number or grapheme id")
      end
    end
  end
end
