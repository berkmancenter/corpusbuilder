module Images
  class Preprocess < Action::Base
    attr_accessor :image

    validates :image, presence: true

    def execute
      binarize
      deskew
      dewarp
      store
    end

    def binarize
      Kraken.binarize image.image_scan.path, binarized_temp_path
    end

    def deskew
      Leptonica::Tools.deskew binarized_temp_path, deskewed_temp_path
    end

    def dewarp
      Leptonica::Tools.dewarp deskewed_temp_path, dewarped_temp_file
    end

    def store
      image.processed_image = File.open(dewarped_temp_file)
      image.save!
    end

    private

    def binarized_temp_path
      Tempfile.new('binarized').path
    end

    def deskewed_temp_path
      Tempfile.new('deskewed').path
    end

    def dewarped_temp_file
      Tempfile.new('dewarped').path
    end
  end
end
