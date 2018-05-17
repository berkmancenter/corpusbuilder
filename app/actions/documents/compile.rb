require 'csv'
require 'securerandom'

module Documents
  class Compile < Action::Base
    attr_accessor :image_ocr_result, :document, :image_id

    validates_presence_of :document
    validates_presence_of :image_id
    validates_presence_of :image_ocr_result

    def execute
      Rails.logger.info "Compiling the document page for image_id = #{image_id}"

      nodes

      copy_data_into_surfaces
      copy_data_into_zones
      copy_data_into_graphemes
      copy_data_into_graphemes_revisions

      nodes
    end

    def nodes
      @_nodes ||= -> {
        graphemes = []
        zone_graphemes = []
        surfaces = []
        zones = []
        last_surface = nil
        last_zone = nil

        image_ocr_result.elements.each do |element|
          case element.name
          when "surface"
            last_surface = document.surfaces.new area: element.area,
              image_id: @image_id, number: image.order,
              id: SecureRandom.uuid
            surfaces << last_surface
          when "zone"
            dir = Bidi.infer_direction(zone_graphemes.map(&:value).join(''))
            last_zone.direction = Zone.directions[dir] if last_zone.present?
            zone_graphemes = []
            last_zone = last_surface.zones.new area: element.area,
              id: SecureRandom.uuid,
              position_weight: zones.count + 1
            zones << last_zone
          when "grapheme"
            if element.grouping != "directional" && element.grouping != "pop"
              g = last_zone.graphemes.new(
                id: SecureRandom.uuid,
                area: (element.grouping == "pop" ? graphemes.last.area : element.area),
                value: element.value,
                certainty: element.certainty,
                position_weight: graphemes.count + 1
              )
              graphemes << g
              zone_graphemes << g
            end
          else
            fail "Invalid OCR element name: #{element.name}"
          end
        end

        dir = Bidi.infer_direction(zone_graphemes.map(&:value).join(''))
        last_zone.direction = Zone.directions[dir] if last_zone.present?

        OpenStruct.new({
          graphemes: graphemes.to_a,
          surfaces: surfaces.to_a,
          zones: zones.to_a
        })
      }.call
    end

    def copy_data_into_surfaces
      conn = Grapheme.connection.raw_connection

      conn.copy_data "COPY surfaces (id, area, image_id, number, document_id, created_at, updated_at) FROM STDIN CSV" do
        nodes.surfaces.to_a.each do |surface|
           data = [ surface.id, surface.area.to_s,
                    surface.image_id, surface.number,
                    surface.document_id,
                    DateTime.now.to_s(:db), DateTime.now.to_s(:db)
           ]
           conn.put_copy_data data.to_csv
        end
      end
    end

    def copy_data_into_zones
      conn = Grapheme.connection.raw_connection

      conn.copy_data "COPY zones (id, area, direction, position_weight, surface_id, created_at, updated_at) FROM STDIN CSV" do
        nodes.zones.each do |zone|
           data = [ zone.id,
                    zone.area.to_s,
                    Zone.directions[zone.direction],
                    zone.position_weight,
                    zone.surface_id,
                    DateTime.now.to_s(:db), DateTime.now.to_s(:db)
           ]
           conn.put_copy_data data.to_csv
        end
      end
    end

    def copy_data_into_graphemes
      conn = Grapheme.connection.raw_connection

      Rails.logger.info "Using Postgres COPY to add #{nodes.graphemes.count} graphemes"

      # todo: use the new copy_data added to ApplicationRecord
      conn.copy_data "COPY graphemes (id, area, value, certainty, position_weight, zone_id, created_at, updated_at) FROM STDIN CSV" do
        nodes.graphemes.each do |grapheme|
           data = [ grapheme.id, grapheme.area.to_s,
                    grapheme.value, grapheme.certainty,
                    grapheme.position_weight, grapheme.zone_id,
                    DateTime.now.to_s(:db), DateTime.now.to_s(:db)
           ]
           conn.put_copy_data data.to_csv
        end
      end
    end

    def copy_data_into_graphemes_revisions
      revisions = [ master_branch.revision, master_branch.working ]

      revisions.each do |revision|
        execute_copy_into_graphemes_revisions(revision)
      end
    end

    def execute_copy_into_graphemes_revisions(revision)
      conn = Grapheme.connection.raw_connection

      grapheme_ids = nodes.graphemes.map(&:id)

      Rails.logger.info "Using Postgres COPY to add #{nodes.graphemes.count} graphemes to the revision #{revision.id}"

      conn.copy_data "COPY #{revision.graphemes_revisions_partition_table_name} (grapheme_id) FROM STDIN CSV" do
        grapheme_ids.each do |grapheme_id|
          conn.put_copy_data "#{grapheme_id}\n"
        end
      end
    end

    def master_branch
      @_master_branch ||= document.master
    end

    def image
      @_image ||= Image.find @image_id
    end

    def create_development_dumps?
      true
    end
  end
end
