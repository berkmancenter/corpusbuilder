module Images
  class BaseOCR < Action::Base
    attr_accessor :image

    validates :image, presence: true

    def execute
      raise StandardError, "BaseOCR should be extended by inheritamnce - not used directly"
    end

    def file_path
      @_file_path ||= TempfileUtils.next_path('hocr_output')
    end

    def image_file_path
      image.processed_image.path
    end
  end
end


