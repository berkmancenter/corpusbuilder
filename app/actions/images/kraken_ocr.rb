module Images
  class KrakenOCR < Action::Base
    attr_accessor :image

    validates :image, presence: true

    def execute
      throw :implement_me
    end
  end
end

