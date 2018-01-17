module Documents
  class CompileCorrections < Action::Base
    attr_accessor :grapheme_ids, :text, :boxes

    validates :grapheme_ids, presence: true
    validates :text, presence: true
    validates :boxes, presence: true

    validate :box_for_each_word

    def execute
      line_diff.word_diffs.map do |word_diff|
        word_diff.grapheme_diffs
      end.map do |grapheme_diff|
        grapheme_diff.to_spec
      end
    end

    def line_diff
      @_line_diff ||= LineDiff.new(grapheme_ids, text, boxes)
    end

    class CorrectionDiff
      def needleman_wunsch(from, to, options = {}, &block)
        Shared::NeedlemanWunsch.run!(
          from: from,
          to: to,
          gap_penalty: options.fetch(:gap_penalty, -1),
          score_fn: block
        ).result
      end

      def levenshtein(first, second)
        if first.length == second.length
          Shared::Levenshtein.run!(
            first: first,
            second: second
          ).result
        else
          second.count
        end
      end

      def graphemes_need_change(from, to)
        value_differs = from.value != to.value
        area_differs = [
          from.area.ulx - to.area.ulx,
          from.area.uly - to.area.uly,
          from.area.lrx - to.area.lrx,
          from.area.lry - to.area.lry
        ].any? { |diff| diff.abs >= 1 }

        value_differs || area_differs
      end
    end

    class LineDiff < CorrectionDiff
      attr_accessor :grapheme_ids, :text, :boxes

      def initialize(grapheme_ids, text, boxes)
        @grapheme_ids = grapheme_ids
        @text = text
        @boxes = boxes
      end

      def word_diffs
        @_word_diffs ||= -> {
          gap = -> (word) {
            -1 * word.count
          }

          alignments = needleman_wunsch(visually_sorted_source_words, visually_sorted_entered_words,
                                        gap_penalty: gap) do |left, right|
            if left.count != right.count
              -1 * [ left.count, right.count ].max
            elsif left.zip(right).any? { |l, r| graphemes_need_change(l, r) }
              -1 * levenshtein(left.text, right.text)
            else
              left.count
            end
          end

          alignments.first.zip(alignments.last).map do |source, entered|
            WordDiff.new(source, entered, self)
          end.select(&:differ?)
        }.call
      end

      def surface_number
        @_surface_number ||= source_graphemes.first.zone.surface.number
      end

      def source_words
        @_source_words ||= -> {
          initial_state = OpenStruct.new({ result: [], last_lrx: nil })

          source_graphemes_filtered.sort_by { |g| g.area.ulx }.inject(initial_state) do |state, grapheme|
            if state.last_lrx.nil? || grapheme.area.ulx - state.last_lrx > 0
              state.result.push([])
            end

            state.result[ state.result.count - 1 ].push(grapheme)
            state.last_lrx = grapheme.area.lrx

            state
          end.result.map do |graphemes|
            Word.new(graphemes)
          end
        }.call
      end

      def visually_sorted_source_words
        source_words.sort_by { |word| word.area.ulx }
      end

      def entered_words
        @_entered_words ||= -> {
          entered_sorted_visually_text_words.each_with_index.map do |text_word, word_index|
            visual_indices = Bidi.to_visual_indices(text_word, rtl? ? :rtl : :ltr)

            graphemes = text_word.chars.each_with_index.map do |_, char_logical_index|
              char_visual_index = visual_indices[char_logical_index]

              box = sorted_boxes[word_index]
              byebug if box.nil?
              width = box[:lrx] - box[:ulx]
              delta_x = ((width / (1.0 * text_word.chars.count)) * char_visual_index)
              delta_x_end = ((width / (1.0 * text_word.chars.count)) * (char_visual_index + 1))

              area = Area.new ulx: box[:ulx] + delta_x,
                lrx: box[:ulx] + delta_x_end,
                uly: box[:uly],
                lry: box[:lry]

              Grapheme.new value: text_word[char_logical_index],
                area: area,
                position_weight: char_logical_index
            end

            Word.new(graphemes)
          end
        }.call
      end

      def visually_sorted_entered_words
        entered_words.sort_by { |word| word.area.ulx }
      end

      def sorted_boxes
        @_sorted_boxes ||= @boxes.map do |box|
          {
            ulx: box[:ulx].to_f.round,
            uly: box[:uly].to_f.round,
            lrx: box[:lrx].to_f.round,
            lry: box[:lry].to_f.round
          }
        end.sort_by { |box| box[:ulx] }
      end

      def source_graphemes_filtered
        @_source_graphemes_filtered ||= source_graphemes.select do |grapheme|
          codepoint = grapheme.value.codepoints.first
          codepoint != 0x202c && codepoint != 0x200f && codepoint != 0x200e
        end
      end

      def rtl?
        !ltr?
      end

      def ltr?
        @_ltr ||= source_graphemes.first.value.codepoints.first === 0x200e
      end

      def source_graphemes
        @_source_graphemes ||= Grapheme.where(id: @grapheme_ids).to_a
      end

      def entered_sorted_visually_text_words
        @_entered_sorted_visually_text_words ||= -> {
          words = normalized_entered_text.split(/\s+/)

          rtl? ? words.reverse : words
        }.call
      end

      def normalized_entered_text
        @_normalized_entered_text ||= -> {
          @text.codepoints.select do |codepoint|
            codepoint != 0x200e && codepoint != 0x200f && codepoint != 0x202c
          end.pack("U*").strip
        }.call
      end
    end

    class Word
      include Enumerable

      def initialize(graphemes)
        @graphemes = graphemes
      end

      def [](index)
        logically_ordered[index]
      end

      def each(&block)
        logically_ordered.each(&block)
      end

      def count
        @graphemes.count
      end

      def logically_ordered
        @_logically_ordered ||= @graphemes.sort_by(&:position_weight)
      end

      def visually_ordered
        @_visually_ordered ||= @graphemes.sort_by { |g| g.area.ulx }
      end

      def text
        logically_ordered.map(&:value).join('')
      end

      def has_new?
        logically_ordered.any? { |g| g.id.nil? }
      end

      def ==(other)
        text == other.text &&
          area == other.area
      end

      def area
        @_area ||= Area.new(
          ulx: visually_ordered.first.area.ulx,
          uly: visually_ordered.first.area.uly,
          lrx: visually_ordered.last.area.lrx,
          lry: visually_ordered.last.area.lry
        )
      end

      def inspect
        "<Word #{ has_new? ? '=N=' : '' } text: \"#{ text }\" area: #{ area }>"
      end
    end

    class WordDiff < CorrectionDiff
      attr_accessor :source, :entered, :line_diff

      def initialize(source, entered, line_diff)
        @source = source
        @entered = entered
        @line_diff = line_diff
      end

      def grapheme_diffs
        @_grapheme_diffs ||= -> {
          source_alignment, entered_alignment = needleman_wunsch(source, entered,
                                                                 gap_penalty: -1) do |left, right|
            graphemes_need_change(left, right) ? -1 : 1
          end

          source_alignment.zip(entered_alignment).map do |from, to|
            GraphemeDiff.new(from, to, self)
          end.select(&:differ?)
        }.call
      end

      def differ?
        source != entered
      end

      def inspect
        "<WordDiff source: #{ @source.inspect } entered: #{ @entered.inspect }>"
      end
    end

    class GraphemeDiff < CorrectionDiff
      attr_accessor :source, :entered, :word_diff

      def initialize(source, entered, word_diff)
        @source = source
        @entered = entered
        @word_diff = word_diff
      end

      def to_spec
        if addition?
          {
            value: entered.value,
            area: entered.area,
            surface_number: word_diff.line_diff.surface_number,
            position_weight: entered.position_weight
          }
        elsif deletion?
          {
            id: source.id,
            grapheme: source,
            delete: true
          }
        elsif modification?
          {
            id: source.id,
            grapheme: source,
            value: entered.value,
            area: entered.area,
            surface_number: word_diff.line_diff.surface_number
          }
        else
          raise StandardError, "No change spec for diff pointing at equal graphemes"
        end
      end

      def inspect_grapheme(g)
        g.nil? ? "<nil>" : "| #{ g.value } @: #{ g.area } #: #{ g.position_weight } |"
      end

      def inspect
        "<GraphemeDiff source: #{ inspect_grapheme(source) } || entered: #{ inspect_grapheme(entered) } >"
      end

      def differ?
        addition? || deletion? || modification?
      end

      def addition?
        source.nil? && entered.present?
      end

      def deletion?
        source.present? && entered.nil?
      end

      def modification?
        source.present? && entered.present? &&
          ( source.value != entered.value || source.area != entered.area )
      end
    end

   #def execute
   #  compare_pairs.first.zip(compare_pairs.last).each { |word_pair| word_pair[0].each_with_index { |g, idx| puts "#{g.try(:value)} (#{g.try(:area)}) => #{word_pair[1][idx].try(:value)} (#{word_pair[1][idx].try(:area)})" }; puts "---";  }

   #  with_positioning compare_items
   #  throw :halt
   #end

   #def surface_number
   #  @_surface_number ||= source_graphemes.first.zone.surface.number
   #end

   #def addition(target, index)
   #  {
   #    value: target.value,
   #    word_id: index,
   #    area: target.area,
   #    surface_number: surface_number,
   #    position_weight: target.position_weight
   #  }
   #end

   #def deletion(source, index)
   #  {
   #    id: source.id,
   #    word_id: index,
   #    grapheme: source,
   #    delete: true
   #  }
   #end

   #def modification(source, target, index)
   #  {
   #    id: source.id,
   #    word_id: index,
   #    grapheme: source,
   #    value: target.value,
   #    area: target.area,
   #    surface_number: surface_number
   #  }
   #end

   #def compare_items
   #  @_compare_items ||= compare_pairs.first.zip(compare_pairs.last).each_with_index.map do |word_pair, index|
   #    # word_pairs :: [ [ <Grapheme>, ... ], [ <Grapheme>, ... ] ]
   #    old_word, new_word = word_pair

   #    if old_word.nil?
   #      new_word.map do |target|
   #        addition(target, index)
   #      end
   #    elsif new_word.nil?
   #      old_word.map do |source|
   #        deletion(source, index)
   #      end
   #    else
   #      from, to = needleman_wunsch(old_word, new_word, gap_penalty: -1) do |left, right|
   #        if graphemes_need_change(left, right)
   #          -1
   #        else
   #          1
   #        end
   #      end
   #      # from :: [ <Grapheme | nil>, ... ]

   #      from.zip(to).map do |pair|
   #        # pair :: [ <Grapheme | nil>, <Grapheme | nil> ]
   #        source, target = pair

   #        if source.nil?
   #          addition(target, index)
   #        elsif target.nil?
   #          deletion(source, index)
   #        elsif graphemes_need_change(source, target)
   #          modification(source, target, index)
   #        else
   #          {
   #            same: true,
   #            word_id: index,
   #            grapheme: source
   #          }
   #        end
   #      end
   #    end

   #  end.flatten
   #end

   #def with_positioning(items)
   #  initial_state = OpenStruct.new({
   #    prev_position: source_graphemes.first.position_weight,
   #    last_position: source_graphemes.last.position_weight,
   #    span: [ ],
   #    result: [ ]
   #  })

   #  by_words = items.group_by { |i| i[:word_id] }
   #  word_ids = (0..words.count-1).to_a
   #  word_ids.reverse! if paragraph_direction == :rtl

   #  sorted = word_ids.map do |word_index|
   #    word = by_words[word_index]

   #    word.sort_by { |i| i.has_key?(:grapheme) ? i[:grapheme].position_weight : i[:position_weight] }
   #  end.flatten

   #  #byebug

   #  sorted.concat([ nil ]).inject(initial_state) do |state, item|
   #    if item.nil? || item.has_key?(:same)
   #      # now compute position weights for the items
   #      # gathered in the current span:

   #      start_weight = state.prev_position
   #      end_weight = item.nil? ? state.last_position : item[:grapheme].position_weight

   #      state.span.each_with_index do |span_item, index|
   #        weight_delta = ((end_weight - start_weight) / (1.0 + state.span.count)) * (index + 1)

   #        span_item[:position_weight] = start_weight + weight_delta
   #      end

   #      state.span = [ ]
   #      #state.last_position = end_weight
   #      state.prev_position = end_weight
   #    elsif !item.has_key?(:delete)
   #      # we have either addition or modification
   #      # adding to the current span:

   #      state.span << item
   #    end

   #    state.result.push(item) if !item.nil? && !item.has_key?(:same)

   #    state
   #  end.result
   #end

   ## [ <Object>, ... ] -> [ <Object>, ... ] -> [ [ <Object | nil>, ... ], [ <Object | nil>, ... ] ]
   #def needleman_wunsch(from, to, options = {}, &block)
   #  Shared::NeedlemanWunsch.run!(
   #    from: from,
   #    to: to,
   #    gap_penalty: options.fetch(:gap_penalty, -1),
   #    score_fn: block
   #  ).result
   #end

   #def graphemes_need_change(from, to)
   #  value_differs = from.value != to.value
   #  area_differs = [
   #    from.area.ulx - to.area.ulx,
   #    from.area.uly - to.area.uly,
   #    from.area.lrx - to.area.lrx,
   #    from.area.lry - to.area.lry
   #  ].any? { |diff| diff.abs >= 1 }

   #  value_differs || area_differs
   #end

   ## an array of arrays of graphemes
   ## each  grapheme array represents a word
   ## it returns source words as well as newly instantiated
   ## words consiting of grapheme canditates
   ##
   ## [ [ <Grapheme>, ... ], [ <Grapheme>, ... ] ]
   #def compare_pairs
   #  @_compare_pairs ||= -> {
   #    words.each do |word|
   #      Rails.logger.info "==> WORD | #{ word }"
   #    end

   #    # candidate word boxes with graphemes from left to right
   #    candidates = words.zip(sorted_boxes).map do |pair|
   #      word, box = pair
   #      width = box[:lrx] - box[:ulx]

   #      sorted_chars = word.chars # bidi.to_visual(word, paragraph_direction).chars

   #      sorted_chars.zip(word.chars).each_with_index.map do |chars, index|
   #        _, char = chars

   #        delta_x = ((width / (1.0 * word.chars.count)) * index)
   #        delta_x_end = ((width / (1.0 * word.chars.count)) * (index + 1))

   #        area = Area.new ulx: box[:ulx] + delta_x,
   #          lrx: box[:ulx] + delta_x_end,
   #          uly: box[:uly],
   #          lry: box[:lry]

   #        Grapheme.new value: char,
   #          area: area,
   #          position_weight: index
   #      end
   #    end

   #    #byebug

   #    gap = -> (word) {
   #      -1 * word.count
   #    }

   #    needleman_wunsch(sorted_source_words, candidates, gap_penalty: gap) do |left, right|
   #      if left.count != right.count
   #        -1 * [ left.count, right.count ].max
   #      elsif left.zip(right).any? { |l, r| graphemes_need_change(l, r) }
   #        -1 * levenshtein(left, right)
   #      else
   #        left.count
   #      end
   #    end
   #  }.call
   #end

   #def levenshtein(first, second)
   #  if first.count == second.count
   #    Shared::Levenshtein.run!(
   #      first: first,
   #      second: second
   #    ).result
   #  else
   #    second.count
   #  end
   #end

   #def paragraph_direction
   #  @_paragraph_direction ||= source_graphemes.first.value.codepoints.first == 0x200f ? :rtl : :ltr
   #end

   #def is_rtl
   #  paragraph_direction == :rtl
   #end

   #def source_graphemes
   #  @_source_graphemes ||= Grapheme.where(id: grapheme_ids).to_a
   #end

   #def sorted_source_words
   #  @_sorted_source_words ||= -> {
   #    # each line starts with the directionality grapheme
   #    # and may end with the pop directionality:

   #    graphemes = source_graphemes.each_with_index.select do |grapheme, index|
   #      codepoint = grapheme.value.codepoints.first

   #      codepoint != 0x202c && codepoint != 0x200f && codepoint != 0x200e
   #    end

   #    graphemes = graphemes.map(&:first)

   #    init_state = OpenStruct.new({
   #      result: [ ],
   #      last_lrx: nil
   #    })

   #    graphemes.sort_by { |g| g.area.ulx }.inject(init_state) do |state, grapheme|
   #      if state.last_lrx.nil? || grapheme.area.ulx > state.last_lrx
   #        state.result.push([ grapheme ])
   #      else
   #        state.result[ state.result.count - 1 ].push(grapheme)
   #      end

   #      state.last_lrx = grapheme.area.lrx
   #      state
   #    end.result.map do |word|
   #      word.sort_by(&:position_weight)
   #    end
   #  }.call
   #end

   #def sorted_boxes
   #  @_sorted_boxes ||= boxes.map do |box|
   #    {
   #      ulx: box[:ulx].to_f.round,
   #      uly: box[:uly].to_f.round,
   #      lrx: box[:lrx].to_f.round,
   #      lry: box[:lry].to_f.round
   #    }
   #  end.sort_by { |box| box[:ulx] }
   #end

   #def normalized_text
   #  @_normalized_text ||= -> {
   #    text.codepoints.each_with_index.select do |codepoint, index|
   #      codepoint != 0x200e && codepoint != 0x200f && codepoint != 0x202c
   #    end.map(&:first).pack("U*").strip
   #  }.call
   #end

   #def words
   #  @_words ||= -> {
   #    words = normalized_text.split(/\s+/).reject(&:empty?)
   #    sorted_words = paragraph_direction == :rtl ? words.reverse : words

   #    sorted_words.map do |word|
   #      if paragraph_direction == :rtl
   #        Bidi.to_visual word, :rtl
   #      else
   #        word
   #      end
   #    end
   #  }.call
   #end

   #def box_for_each_word
   #  if words.count != boxes.count
   #    errors.add(:boxes, "must match in count (given: #{ boxes.count }) with the number of words in text (given: #{ words.count } - #{words.inspect})")
   #  end
   #end

   #def create_development_dumps?
   #  true
   #end
  end
end
