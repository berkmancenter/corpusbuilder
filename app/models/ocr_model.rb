class OcrModel < ApplicationRecord
  enum backend: [ :tesseract, :kraken ]

  validates :backend, inclusion: { in: backends.keys }

  has_many :ocr_model_samples

  attr_accessor :file
  attr_accessor :samples

  class Simple < Grape::Entity
    expose :id
    expose :backend
    expose :name
    expose :description
    expose :languages do |model|
      model.languages.map do |lang|
        info = LanguageList::LanguageInfo.find(lang)
        {
          code: info.iso_639_3,
          name: info.name
        }
      end
    end
    expose :scripts do |model|
      ScriptList.find(model.scripts).map do |script|
        {
          code: script.code,
          name: script.name
        }
      end
    end
    expose :samples do |model|
      model.ocr_model_samples.map do |sample|
        sample.sample_image_url
      end
    end
    expose :version_code
  end
end
