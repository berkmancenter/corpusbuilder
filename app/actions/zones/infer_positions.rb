module Zones
  class InferPositions < Action::Base
    attr_accessor :zone

    def execute
      # assign the median position weights of the graphemes
      # taking the median is simply not to fall for the outlying
      # erroneous weight that might have crippled into the testing data

      zone.update_attribute(:position_weight, grapheme_weights.median)
    end

    def grapheme_weights
      memoized do
        zone.graphemes.select(:position_weight).map(&:position_weight)
      end
    end
  end
end
