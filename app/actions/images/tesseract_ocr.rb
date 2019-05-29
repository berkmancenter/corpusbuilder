module Images
  class TesseractOCR < BaseOCR
    include Silenceable

    def execute
      silently do
        Rails.logger.info "Running Tesseract with: #{command}"

        tesseract_output = `#{command}`
        tesseract_status = $?

        Rails.logger.info "Tesseract returned #{tesseract_output}"
        Rails.logger.info "Tesseract status #{tesseract_status}"

        if !tesseract_status.success?
          raise StandardError, "Tesseract returned abnormally. Status: #{tesseract_status}. Output: #{tesseract_output}"
        end

        Rails.logger.debug "Tesseract resulting file should be found at #{file_path}.#{format}"

        "#{file_path}.#{format}"
      end
    end

    def command
      "tesseract #{image_file_path} #{file_path} --oem 1 -l #{model} #{format}"
    end

    def model
      ocr_models.map(&:filename).join("+")
    end
  end
end
