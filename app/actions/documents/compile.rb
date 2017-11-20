require 'csv'
require 'securerandom'

module Documents
  class Compile < Action::Base
    attr_accessor :image_ocr_result, :document, :image_id

    validates_presence_of :document
    validates_presence_of :image_id
    validates_presence_of :image_ocr_result

    def execute
      copy_data_into_graphemes
      copy_data_into_graphemes_revisions
    end

    def graphemes
      @_graphemes ||= -> {
        graphemes = []

        image_ocr_result.elements.each do |element|
          case element.name
          when "surface"
            @_surface = @document.surfaces.create! area: element.area,
              image_id: @image_id, number: image.order
          when "zone"
            @_zone = @_surface.zones.create! area: element.area
          when "grapheme"
            g = @_zone.graphemes.new(
              id: SecureRandom.uuid,
              area: element.area,
              value: element.value,
              certainty: element.certainty,
              position_weight: graphemes.count + 1
            )
            graphemes << g
          else
            fail "Invalid OCR element name: #{element.name}"
          end
        end

        graphemes
      }.call
    end

    def copy_data_into_graphemes
      conn = Grapheme.connection.raw_connection

      graphemes = self.graphemes.to_a

      conn.copy_data "COPY graphemes (id, area, value, certainty, position_weight, zone_id, created_at, updated_at) FROM STDIN CSV DELIMITER ';'" do
        graphemes.each do |grapheme|
           data = [ grapheme.id, grapheme.area.to_s,
                    grapheme.value, grapheme.certainty,
                    grapheme.position_weight, grapheme.zone_id,
                    DateTime.now.to_s(:db), DateTime.now.to_s(:db)
           ]
           conn.put_copy_data "#{data.join(';')}\n"
        end
      end
    end

    def copy_data_into_graphemes_revisions
      revisions = [ master_branch.revision.id, master_branch.working.id ]

      revisions.each do |revision_id|
        execute_copy_into_graphemes_revisions(revision_id)
      end
    end

    def execute_copy_into_graphemes_revisions(revision_id)
      conn = Grapheme.connection.raw_connection

      grapheme_ids = graphemes.map(&:id)

      conn.copy_data "COPY graphemes_revisions (grapheme_id, revision_id) FROM STDIN CSV" do
        grapheme_ids.each do |grapheme_id|
          conn.put_copy_data "#{grapheme_id},#{revision_id}\n"
        end
      end
    end

    def master_branch
      @_master_branch ||= document.master
    end

    def image
      @_image ||= Image.find @image_id
    end
  end
end
