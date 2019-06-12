module OcrModels
  class TranscribeZones < Action::Base
    attr_accessor :model_id
    attr_accessor :zone_ids
    attr_accessor :base_path

    def execute
      FileUtils.mkdir_p base_path

      results = ocr_backend.ocr \
        image_file_paths: image_paths,
        ocr_models: [model],
        format: 'txt'

      ix = 0

      zone_ids.zip(results).inject({}) do |res, arr|
        res[arr.first] = {
          result: arr.last.gsub(/\n/, '') || '',
          image_path: image_paths[ix]
        }
        ix += 1
        res
      end
    end

    def image_paths
      memoized do
        zones.map do |zone|
          base_path.join("#{zone.id}.png").tap do |path|
            if !File.exist? path
              image_data = ChunkyPNG::Image.from_file \
                zone.surface.image.processed_image.path

              Documents::Export::ExportLinePng.run! \
                zone: zone,
                document: zone.surface.document,
                dir_path: base_path,
                image: image_data,
                save: true
            end
          end
        end
      end
    end

    def model
      memoized do
        OcrModel.find model_id
      end
    end

    def zones
      memoized do
        records = Zone.find(zone_ids).group_by(&:id)

        zone_ids.map { |id| records[id].first }
      end
    end

    def ocr_backend
      model.ocr_backend
    end
  end
end

