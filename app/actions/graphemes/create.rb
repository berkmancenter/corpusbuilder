module Graphemes
  class Create < Action::Base
    attr_accessor :revision, :area, :value, :surface_number

    def execute
      @revision.graphemes << Grapheme.create!(area: @area, value: @value, zone_id: zone_id)
    end

    private

    def zone_id
      @_zone_id ||= Zone.where("area @> ?", @area.to_s).
        where(surface_id: surface_id).
        take(1).
        pluck(:id).
        first
    end

    def surface_id
      @_surface_id ||= Surface.where(document_id: @revision.document_id).
        where(number: @surface_number).
        pluck(:id).
        first
    end
  end
end
