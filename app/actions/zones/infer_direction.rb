module Zones
  class InferDirection < Action::Base
    attr_accessor :zone

    def execute
      zone.update_attribute(:direction, direction)
    end

    def direction
      Zone.directions[ direction_symbol ]
    end

    def direction_symbol
      memoized do
        grapheme = zone.
          graphemes.
          where(value: [0x200f, 0x200e].map { |cp| [cp].pack("U*") }).
          first

        if grapheme.present?
          grapheme.value.codepoints.first == 0x200f ? :rtl : :ltr
        else
          Bidi.infer_direction(zone.graphemes.map(&:value).join(''))
        end
      end
    end
  end
end

