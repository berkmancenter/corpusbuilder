class OcrBackend::Tesseract < OcrBackend::Base
  def ocr(image_file_path:, ocr_models:, out_path:, format: 'hocr')
    model = ocr_models.map(&:filename).join("+")
    out = out_path.to_s.split('.').reverse.drop(1).reverse.join('.')

    command = "tesseract #{image_file_path} #{out} --oem 1 -l #{model} #{format}"

    run_command(command).tap do |result|
      if !result.status.success?
        raise StandardError,
          "Tesseract returned abnormally. Status: #{result.status}. Output: #{result.output}"
      end
    end
  end
end

