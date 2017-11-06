module Images
  class Preprocess < Action::Base
    attr_accessor :image

    validates :image, presence: true

    def execute
      # todo: implement me
    end
  end
end
