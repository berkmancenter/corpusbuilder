class OcrBackend::Base
  include Singleton
  include Silenceable
  include Memoizable

  def ocr(image:, ocr_models:, out_path:)
    raise NotImplementedError
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
