module OcrModels
  class Persist < Action::Base
    attr_accessor :model

    def execute
      model.languages.reject!(&:empty?)
      model.scripts.reject!(&:empty?)

      process_model_file if model.file.present?

      model.save
    end

    def process_model_file
      if model.tesseract?
        InstallTesseractModel.run! model: model
      elsif model.kraken?
        InstallKrakenModel.run! model: model
      else
        raise ArgumentError, "Expected a tesseract or kraken model but got '#{model.backend}' instead"
      end
    end
  end
end
