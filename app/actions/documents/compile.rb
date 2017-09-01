module Documents
  class Compile < Action::Base
    attr_accessor :image_ocr_result

    def execute
      :ok
    end
  end
end
