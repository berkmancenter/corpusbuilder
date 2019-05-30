module OcrModels
  class TranscribeZone < Action::Base
    attr_accessor :model_id
    attr_accessor :zone_id

    def execute
      FileUtils.mkdir_p dir_path

      ocr_backend.ocr \
        image_file_path: image_path,
        ocr_models: [model],
        out_path: txt_path,
        format: 'txt'

      File.read(txt_path).gsub(/\n|\f/, '')
    end

    def image_path
      memoized do
        dir_path.join("#{zone.id}.png").tap do |path|
          if !File.exist? path
            Documents::Export::ExportLinePng.run! \
              zone: zone,
              document: zone.surface.document,
              dir_path: dir_path,
              image: image_data,
              save: true
          end
        end
      end
    end

    def image_data
      memoized do
        ChunkyPNG::Image.from_file \
          zone.surface.image.processed_image.path
      end
    end

    def txt_path
      memoized do
        dir_path.join "#{zone.id}.txt"
      end
    end

    def dir_path
      Rails.root.join 'public',
        'export',
        'zones',
        zone.id
    end

    def model
      memoized do
        OcrModel.find model_id
      end
    end

    def zone
      memoized do
        Zone.find zone_id
      end
    end

    def ocr_backend
      model.ocr_backend
    end
  end
end

