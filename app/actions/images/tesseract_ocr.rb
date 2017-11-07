module Images
  class TesseractOCR < Action::Base
    attr_accessor :image

    validates :image, presence: true

    def execute
      Rails.logger.info "Running Tesseract with: #{command}"
      tesseract_output = `#{command}`
      tesseract_status = $?
      Rails.logger.info "Tesseract returned #{tesseract_output}"
      Rails.logger.info "Tesseract status #{tesseract_status}"

      if !tesseract_status.success?
        raise "Tesseract returned abnormally. Status: #{tesseract_status}. Output: #{tesseract_output}"
      end

      Que.logger.debug "Tesseract resulting file should be found at #{file_path}.hocr"

      "#{file_path}.hocr"
    end

    def file_path
      @_file_path ||= Tempfile.new.path
    end

    def command
      "tesseract #{image_file_path} #{file_path} --oem 1 -l #{model} hocr"
    end

    def image_file_path
      image.image_scan.path
    end

    def model
      # todo: implement switching between models
      "Arabic"
    end
  end
end
