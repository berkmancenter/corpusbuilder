module Images
  class OCR < Action::Base
    attr_accessor :image, :ocr_models

    validates :image, presence: true

    def execute
      result = ocr_backend.ocr \
        image_file_path: image.processed_image.path,
        ocr_models: ocr_models,
        out_path: file_path

      Rails.logger.debug "The OCR results file returned: #{file_path}"

      if !File.exist?(file_path)
        raise StandardError,
          "Output file has not been found. Output file path: #{file_path}"
      end

      file = File.new(file_path)

      image.hocr = file
      image.save!

      file.close

      image
    end

    def file_path
      memoized do
        TempfileUtils.next_path('hocr_output')
      end
    end

    def ocr_backend
      ocr_models.first.ocr_backend
    end
  end
end

