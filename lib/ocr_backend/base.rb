class OcrBackend::Base
  include Singleton
  include Silenceable
  include Memoizable

  def ocr_list(image_file_paths:, ocr_models:, format: 'hocr')
    raise NotImplementedError
  end

  def ocr(image_file_paths:, ocr_models:, format: 'hocr')
    results = ocr_list image_file_paths: image_file_paths,
      ocr_models: ocr_models,
      format: format

    split results: results, format: format
  end

  def split(results:, format:)
    if !results.is_a? String
      raise ArgumentError, \
        "Expected ocr_list to return a string"
    end

    if format.to_s == 'txt'
      split_txt results
    elsif format.to_s == 'hocr'
      split_hocr results
    else
      results
    end
  end

  def split_txt(results)
    results.split(/\f/)
  end

  def split_hocr(results)
    Nokogiri::XML(results).search('.ocr_page').map(&:to_s)
  end

  def run_command(command)
    Rails.logger.info "Running ocr command: #{command}"

    output = `#{command}`
    status = $?

    Rails.logger.info "Ocr returned #{output}"
    Rails.logger.info "Ocr status #{status}"

    if !status.success?
      Rails.logger.info "Ocr backend returned abnormally. Status: #{status}. Output: #{output}"
    end

    OpenStruct.new output: output,
      status: status
  end
end
