module Images
  class KrakenOCR < BaseOCR
    def execute
      Rails.logger.info "Running Kraken with: #{command}"

      kraken_output = `#{command}`
      kraken_status = $?

      Rails.logger.info "Kraken returned #{kraken_output}"
      Rails.logger.info "Kraken status #{kraken_status}"

      if !kraken_status.success?
        raise StandardError, "Kraken returned abnormally. Status: #{kraken_status}. Output: #{kraken_output}"
      end

      Rails.logger.debug "Kraken resulting file should be found at #{file_path}.hocr"

      file_path
    end

    def command
      "kraken -i #{image_file_path} #{file_path} binarize segment ocr -h -m arabic-hayawan.clstm"
    end
  end
end

