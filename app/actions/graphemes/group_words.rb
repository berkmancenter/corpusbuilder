require 'descriptive_statistics'

module Graphemes
  class GroupWords < Action::Base
    attr_accessor :graphemes

    def execute
      init_state = OpenStruct.new({
        result: [ ],
        last_lrx: nil
      })

      in_reading_order.inject(init_state) do |state, grapheme|
        if state.last_lrx.nil? || grapheme.area.ulx > state.last_lrx
          state.result.push([grapheme])
        else
          state.result[ state.result.count - 1 ].push(grapheme)
        end

        state.last_lrx = grapheme.area.lrx

        state
      end.result.map do |word|
        # within a word preserve immediate logical order
        word.sort_by(&:position_weight)
      end.sort_by do |word|
        # now sort each word logically
        # this step is needed in case position_weight of a grapheme
        # that visually belongs to some other word would otherwise
        # be included in the wrong logical place. Sorting by median
        # to rule out outliers

        word.map(&:position_weight).median
      end
    end

    def in_reading_order
      graphemes.sort_by { |grapheme| grapheme.area.ulx }
    end
  end
end
