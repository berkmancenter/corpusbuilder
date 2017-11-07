module Images
  class OCR < Action::Base
    attr_accessor :image, :backend

    validates :image, presence: true
    validates :backend, inclusion: { in: [ :tesseract, :kraken ] }

    # todo: specify the language to use

    def execute
      file_path = backend_action.run!(image: image).result
      file = File.new(file_path)
      image.hocr = file
      image.save!
      file.close
      image
    end

    def backend_action
      case backend
      when :tesseract
        Images::TesseractOCR
      when :kraken
        Images::KrakenOCR
      end
    end
  end
end

