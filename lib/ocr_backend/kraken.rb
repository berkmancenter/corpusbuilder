class OcrBackend::Kraken < OcrBackend::Base
  def ocr(image_file_path:, ocr_models:, out_path:, format: 'hocr')
    model = ocr_models.map(&:filename).map do |n|
      "-m #{n.gsub(".mlmodel", "") + ".mlmodel"}"
    end.join " "

    format_switch = format == 'hocr' ? '-h' : '-t'

    command = "nice -19 kraken -i #{image_file_path} #{out_path} segment ocr #{format_switch} #{model}"

    run_command(command).tap do |result|
      if !result.status.success?
        raise StandardError,
          "Kraken returned abnormally. Status: #{result.status}. Output: #{result.output}"
      end
    end
  end
end

