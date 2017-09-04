module Documents
  class Compile < Action::Base
    attr_accessor :image_ocr_result, :document, :image_id

    def validate
      if @document.nil?
        fail "Document required"
      end

      if @image_id.nil?
        fail "Image id required"
      end

      if @image_ocr_result.nil?
        fail "OCR results required"
      end
    end

    def execute
      image_ocr_result.elements.each do |element|
        case element.name
        when "surface"
          @document.surfaces.create! area: element.area,
            image_id: @image_id, number: image.order
        when "zone"
        when "grapheme"
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
