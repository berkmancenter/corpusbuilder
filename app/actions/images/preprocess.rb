module Images
  class Preprocess < Action::Base
    attr_accessor :image

    validates :image, presence: true

    def execute
      #binarize
      deskew
      dewarp
      store
      cleanup

      image
    end

    def binarize
      Kraken.binarize image.image_scan.path, binarized_temp_path
    end

    def deskew
      Leptonica::Tools.deskew binarized_temp_path, deskewed_temp_path
    end

    def dewarp
      Leptonica::Tools.dewarp deskewed_temp_path, dewarped_temp_file
    rescue
      Leptonica::Tools.dewarp_simple deskewed_temp_path, dewarped_temp_file
    end

    def store
      image.processed_image = File.open(dewarped_temp_file)
      image.save!
    end

    def cleanup
      FileUtils.rm [ deskewed_temp_path, dewarped_temp_file ]
    end

    private

    def binarized_temp_path
      @_binarized_temp_path ||= TempfileUtils.next_path('binarized')
    end

    def deskewed_temp_path
      @_deskewed_temp_path ||= TempfileUtils.next_path('deskewed')
    end

    def dewarped_temp_file
      @_dewarped_temp_file ||= TempfileUtils.next_path('dewarped')
    end
  end
end
