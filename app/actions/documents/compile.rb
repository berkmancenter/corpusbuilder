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

      copy_data_into_graphemes
      copy_data_into_graphemes_revisions
    end

    def graphemes
      @_graphemes ||= -> {
        graphemes = []
        zone_graphemes = []

        image_ocr_result.elements.each do |element|
          case element.name
          when "surface"
            @_surface = @document.surfaces.create! area: element.area,
              image_id: @image_id, number: image.order
          when "zone"
            if zone_graphemes.count == 2
              # we only have directionals here so we can get rid of them
              # to have a cleaner document
              graphemes -= zone_graphemes
              @_zone.delete
            end
            zone_graphemes = []
            @_zone = @_surface.zones.create! area: element.area
          when "grapheme"
            g = @_zone.graphemes.new(
              id: SecureRandom.uuid,
              area: (element.grouping == "pop" ? graphemes.last.area : element.area),
              value: element.value,
              certainty: element.certainty,
              position_weight: graphemes.count + 1
            )
            graphemes << g
            zone_graphemes << g
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

      Rails.logger.info "Using Postgres COPY to add #{graphemes.count} graphemes"

      conn.copy_data "COPY graphemes (id, area, value, certainty, position_weight, zone_id, created_at, updated_at) FROM STDIN CSV" do
        graphemes.each do |grapheme|
           data = [ grapheme.id, grapheme.area.to_s,
                    grapheme.value, grapheme.certainty,
                    grapheme.position_weight, grapheme.zone_id,
                    DateTime.now.to_s(:db), DateTime.now.to_s(:db)
           ]
           conn.put_copy_data data.to_csv
        end
      end

      Rails.logger.info "Copying of #{graphemes.count} graphemes done"
    end

    def copy_data_into_graphemes_revisions
      revisions = [ master_branch.revision, master_branch.working ]

      revisions.each do |revision|
        execute_copy_into_graphemes_revisions(revision)
      end
    end

    def execute_copy_into_graphemes_revisions(revision)
      conn = Grapheme.connection.raw_connection

      grapheme_ids = graphemes.map(&:id)

      Rails.logger.info "Using Postgres COPY to add #{graphemes.count} graphemes to the revision #{revision.id}"

      conn.copy_data "COPY #{revision.graphemes_revisions_partition_table_name} (grapheme_id) FROM STDIN CSV" do
        grapheme_ids.each do |grapheme_id|
          conn.put_copy_data "#{grapheme_id}\n"
        end
      end

      Rails.logger.info "Copied #{graphemes.count} graphemes to the revision #{revision.id}"
    end

    def master_branch
      @_master_branch ||= document.master
    end

    def image
      @_image ||= Image.find @image_id
    end
  end
end
