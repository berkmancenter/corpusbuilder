module OcrModels
  class DetectSystemModels < Action::Base
    attr_accessor :default_language, :backend

    def execute
      if backend.nil? || backend == "tesseract"
        insert_existing "TESSDATA_PREFIX", "*.traineddata", "tesseract"
      end

      if backend.nil? || backend == "kraken"
        insert_existing "KRAKEN_DATA_PREFIX", "*.mlmodel", "kraken"
      end
    end

    def insert_existing(prefix, ext, backend)
      Dir[File.join(ENV[prefix], ext)].each do |path|
        filename = path.split("/").last

        OcrModel.where(filename: filename).first.tap do |model|
          if model.nil?
            lang = LanguageList::LanguageInfo.find(
              filename.split(/\p{P}/).first || default_language
            )

            if lang.nil?
              Rails.logger.info "Language for #{ filename } unknown"
            else
              OcrModel.create! filename: filename,
                name: filename.split('.').reverse.drop(1).reverse.join(''),
                backend: backend,
                description: "Default #{backend.humanize} #{filename} model",
                languages: [ lang.iso_639_3 ],
                scripts: [],
                version_code: "0"
            end
          end
        end
      end
    end
  end
end

