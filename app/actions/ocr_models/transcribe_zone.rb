module OcrModels
  class TranscribeZone < Action::Base
    attr_accessor :model_id
    attr_accessor :zone_id

    def execute
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
  end
end

