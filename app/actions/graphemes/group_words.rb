require 'descriptive_statistics'

module Graphemes
  class GroupWords < Action::Base
    attr_accessor :graphemes

    def execute
      return [] if graphemes.empty?

      logical_graphemes.inject([[]]) do |words, grapheme|
        if grapheme.nil?
          words << []
        else
          words[ words.count - 1 ] << grapheme
        end

        words
      end
    end

    def zone
      memoized do
        graphemes.first.zone
      end
    end

    def logical_indices
      memoized do
        Bidi.to_logical_indices(visual_text, zone.direction.to_sym)
      end
    end

    def visual_text
      visual_graphemes.map { |g| g.try(:value) || ' ' }.join('')
    end

    def logical_graphemes
      memoized do
        result = Array.new(visual_graphemes.size)

        logical_indices.each_with_index do |lix, vix|
          result[lix] = visual_graphemes[vix]
        end

        result
      end
    end

    def visual_graphemes
      memoized do
        result = [ ]

        for word in visual_words
          for grapheme in word
            result << grapheme
          end
          result << nil
        end

        result[0..-2]
      end
    end

    def visual_words
      init_state = OpenStruct.new(
        last_lrx: nil,
        result: [ ]
      )

      in_reading_order.inject(init_state) do |state, grapheme|
        if state.last_lrx.nil? || grapheme.area.ulx > state.last_lrx
          state.result.push([ grapheme ])
        else
          state.result[ state.result.count - 1 ].push(grapheme)
        end

        state.last_lrx = grapheme.area.lrx

        state
      end.result
    end

    def in_reading_order
      graphemes.sort_by { |grapheme| grapheme.area.ulx }
    end
  end
end
