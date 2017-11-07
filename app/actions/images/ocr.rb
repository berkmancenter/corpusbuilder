module Images
  class OCR < Action::Base
    attr_accessor :image, :backend

    validates :image, presence: true
    validates :backend, inclusion: { in: [ :tesseract, :kraken ] }

    # todo: specify the language to use

    def execute
      file_path = backend_action.run!(image: image).result
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

    def backend_action
      case backend
      when :tesseract
        Images::TesseractOCR
      when :kraken
        Images::KrakenOCR
      end
    end
  end
end

