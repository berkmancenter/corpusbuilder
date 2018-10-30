module Images
  class OCR < Action::Base
    attr_accessor :image, :ocr_models

    validates :image, presence: true

    def execute
      file_path = backend_action.run!(
        image: image,
        ocr_models: ocr_models
      ).result

      Rails.logger.debug "The OCR results file returned: #{file_path}"

      if !File.exist?(file_path)
        raise StandardError, "Tesseract seems to have returned the results but the outpout file has not been found. Output file path: #{file_path}"
      end

      file = File.new(file_path)
      image.hocr = file
      image.save!
      file.close
      image
    end

    def backend
      ocr_models.first.backend
    end

    def backend_action
      case backend.to_s
      when 'tesseract'
        Images::TesseractOCR
      when 'kraken'
        Images::KrakenOCR
      else
        raise ArgumentError, "Backend should be tesseract or kraken but #{backend} was given"
      end
    end
  end
end

