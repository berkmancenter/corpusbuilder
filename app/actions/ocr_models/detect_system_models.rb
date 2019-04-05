module OcrModels
  class DetectSystemModels < Action::Base
    def execute
      insert_existing "TESSDATA_PREFIX", "*.traineddata", "tesseract"
      insert_existing "KRAKEN_DATA_PREFIX", "*.clstm", "kraken"
      insert_existing "KRAKEN_DATA_PREFIX", "*.mlmodel", "kraken"
      insert_existing "KRAKEN_DATA_PREFIX", "*.pronn", "kraken"
    end

    def insert_existing(prefix, ext, backend)
      Dir[File.join(ENV[prefix], ext)].each do |path|
        filename = path.split("/").last.split(".").first

        OcrModel.where(filename: filename).first.tap do |model|
          if model.nil?
            lang = LanguageList::LanguageInfo.find(filename.split(/\p{P}/).first)

            if lang.nil?
              Rails.logger.info "Language for #{ filename } unknown"
            else
              OcrModel.create! filename: filename,
                name: filename,
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

