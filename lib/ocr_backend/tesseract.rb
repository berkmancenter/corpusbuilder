class OcrBackend::Tesseract < OcrBackend::Base
  def ocr_list(image_file_paths:, ocr_models:, format: 'hocr')
    model = ocr_models.map(&:filename).map { |f| f.split('.').first }.join("+")
    out_path = TempfileUtils.next_path 'tesseract_out'

    images_list = Tempfile.new 'images_list'

    image_file_paths.each do |path|
      images_list << "#{path}\n"
    end

    images_list.close

    command = "nice -19 tesseract #{images_list.path} #{out_path} --oem 1 -l #{model} #{format}"

    run_command(command).tap do |result|
      if !result.status.success?
        raise StandardError,
          "Tesseract returned abnormally. Status: #{result.status}. Output: #{result.output}"
      end
    end

    File.read("#{out_path}.#{format}")
  end
end

