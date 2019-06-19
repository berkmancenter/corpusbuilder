class OcrBackend::Kraken < OcrBackend::Base
  def ocr(image_file_paths:, ocr_models:, format: 'hocr')
    model = ocr_models.map(&:filename).map do |n|
      "-m #{n.gsub(".mlmodel", "") + ".mlmodel"}"
    end.join " "

    image_file_paths.each_slice(10).map do |paths|
      inputs = paths.map do |path|
        "-i #{path} #{path}.#{format}"
      end.join(' ')

      format_switch = format == 'hocr' ? '-h' : '-t'

      command = "nice -19 kraken #{inputs} segment ocr #{format_switch} #{model}"

      run_command(command).tap do |result|
        if !result.status.success?
          msg = "Kraken returned abnormally. Status: #{result.status}. Output: #{result.output}"

          Rails.logger.debug msg
          raise StandardError, msg
        end
      end

      paths.map do |path|
        File.read "#{path}.#{format}"
      end
    end.flatten
  end
end

