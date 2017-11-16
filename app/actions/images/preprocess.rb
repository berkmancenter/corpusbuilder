module Images
  class Preprocess < Action::Base
    attr_accessor :image

    validates :image, presence: true

    def execute
      image.image_scan.recreate_versions! :preprocessed
    end
  end
end
