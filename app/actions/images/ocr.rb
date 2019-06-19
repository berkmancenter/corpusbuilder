module Images
  class OCR < Action::Base
    attr_accessor :images, :ocr_models

    validates :images, presence: true

    def execute
      results = ocr_backend.ocr \
        image_file_paths: image_file_paths,
        ocr_models: ocr_models,
        format: 'hocr'

      images.zip(results).map do |image, hocr_string|
        path = TempfileUtils.next_path('hocr_output')
        File.write path, hocr_string

        file = File.new(path)

        image.hocr = file
        image.save!

        file.close
      end

      images
    end

    def image_file_paths
      memoized do
        images.map(&:processed_image).
          map(&:path)
      end
    end

    def ocr_backend
      ocr_models.first.ocr_backend
    end
  end
end

