module OcrModels
  class Create < Action::Base
    attr_accessor :model

    def execute
      model.languages.reject!(&:empty?)
      model.scripts.reject!(&:empty?)

      model.save
    end
  end
end
