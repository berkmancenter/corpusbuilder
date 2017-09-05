module Documents
  class Compile < Action::Base
    attr_accessor :image_ocr_result, :document, :image_id

    validates_presence_of :document
    validates_presence_of :image_id
    validates_presence_of :image_ocr_result

    def execute
      image_ocr_result.elements.each do |element|
        case element.name
        when "surface"
          @_surface = @document.surfaces.create! area: element.area,
            image_id: @image_id, number: image.order
        when "zone"
          @_zone = @_surface.zones.create! area: element.area
        when "grapheme"
          @_zone.graphemes.create! area: element.area,
            value: element.value, certainty: element.certainty
        else
          fail "Invalid OCR element name: #{element.name}"
        end
      end
    end

    def image
      @_image ||= Image.find @image_id
    end
  end
end
