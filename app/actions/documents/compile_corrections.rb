module Documents
  class CompileCorrections < Action::Base
    attr_accessor :grapheme_ids, :text, :boxes

    validates :grapheme_ids, presence: true
    validates :text, presence: true
    validates :boxes, presence: true

    validate :box_for_each_word

    def execute
      with_positioning compare_items
    end

    def surface_number
      @_surface_number ||= source_graphemes.first.zone.surface.number
    end

    def addition(target)
      {
        value: target.value,
        area: target.area,
        surface_number: surface_number
      }
    end

    def deletion(source)
      {
        id: source.id,
        delete: true
      }
    end

    def modification(source, target)
      {
        old_id: source.id,
        value: target.value,
        area: target.area,
        surface_number: surface_number
      }
    end

    def compare_items
      compare_pairs.map do |word_pair|
        # word_pairs :: [ [ <Grapheme>, ... ], [ <Grapheme>, ... ] ]
        old_word, new_word = word_pair

        if old_word.nil?
          new_word.map do |target|
            addition(target)
          end
        elsif new_word.nil?
          old_word.map do |source|
            deletion(source)
          end
        else
          from, to = needleman_wunsch(old_word, new_word, gap_penalty: -1) do |left, right|
            if graphemes_need_change(left, right)
              -1
            else
              1
            end
          end
          # from :: [ <Grapheme | nil>, ... ]

          from.zip(to).map do |pair|
            # pair :: [ <Grapheme | nil>, <Grapheme | nil> ]
            source, target = pair

            if source.nil?
              addition(target)
            elsif target.nil?
              deletion(source)
            elsif graphemes_need_change(source, target)
              modification(source, target)
            else
              {
                same: true,
                grapheme: source
              }
            end
          end
        end

      end.flatten
    end

    def with_positioning(items)
      initial_state = OpenStruct.new({
        prev_position: source_graphemes.first.position_weight,
        last_position: source_graphemes.last.position_weight,
        span: [ ],
        result: [ ]
      })

      items.concat([ nil ]).inject(initial_state) do |state, item|
        if item.nil? || item.has_key?(:same)
          # now compute position weights for the items
          # gathered in the current span:

          start_weight = state.prev_position
          end_weight = item.nil? ? state.last_position : item[:grapheme].position_weight

          state.span.each_with_index do |span_item, index|
            weight_delta = ((end_weight - start_weight) / (1.0 + state.span.count)) * (index + 1)

            span_item[:position_weight] = start_weight + weight_delta
          end

          state.span = [ ]
          state.last_position = end_weight
        elsif !item.has_key?(:delete)
          # we have either addition or modification
          # adding to the current span:

          state.span << item
        end

        state.result.push(item) if !item.nil? && !item.has_key?(:same)

        state
      end.result
    end

    # [ <Object>, ... ] -> [ <Object>, ... ] -> [ [ <Object | nil>, ... ], [ <Object | nil>, ... ] ]
    def needleman_wunsch(from, to, options = {}, &block)
      gap_penalty = options.fetch(:gap_penalty, -1)

      gap = -> (a) {
        if gap_penalty.is_a? Proc
          gap_penalty.call(a)
        else
          gap_penalty
        end
      }

      # 1. prepare the score and transition matrices:
      score_matrix = (1..to.count + 1).inject([]) { |all, row| all << [0] * (from.count + 1); all }
      transition_matrix = (1..to.count + 1).inject([]) { |all, row| all << [nil] * (from.count + 1); all }

      score_matrix[0][0] = 0
      transition_matrix[0][0] = :done

      for column in 1..from.count
        score_matrix[0][column] = column * gap.call(from)
        transition_matrix[0][column] = :left
      end

      for row in 1..to.count
        score_matrix[row][0] = row * gap.call(to)
        transition_matrix[row][0] = :up
      end

      # 2. compute matrices values preparing for path inference:
      for row in 1..to.count
        for column in 1..from.count
          score = block.call(from[ column - 1 ], to[ row - 1 ])

          values = [
            [ :diag, score_matrix[row - 1 ][ column - 1] + score ],
            [ :up, score_matrix[ row - 1 ][ column ] + gap.call(from) ],
            [ :left, score_matrix[ row ][ column - 1 ] +  gap.call(to) ]
          ]

          choice = values.max_by { |value| value.last }

          score_matrix[ row ][ column ] = choice.last
          transition_matrix[ row ][ column ] = choice.first
        end
      end

      # 3. walk the path filling the alignment arrays:
      from_alignment = [ ]
      to_alignment = [ ]

      row = to.count
      column = from.count

      while row > 0 || column > 0
        direction = transition_matrix[ row ][ column ]

        case direction
        when :diag
          from_alignment.push from[ column - 1 ]
          to_alignment.push to[ row - 1 ]

          row -= 1
          column -= 1
        when :left
          from_alignment.push from[ column - 1 ]
          to_alignment.push nil

          column -= 1
        when :up
          from_alignment.push nil
          to_alignment.push to[ row - 1 ]

          row -= 1
        end
      end

      [
        from_alignment.reverse,
        to_alignment.reverse
      ]
    end

    def graphemes_need_change(from, to)
      from.value != to.value || from.area != to.area
    end

    # an array of arrays of graphemes
    # each  grapheme array represents a word
    # it returns source words as well as newly instantiated
    # words consiting of grapheme canditates
    #
    # [ [ <Grapheme>, ... ], [ <Grapheme>, ... ] ]
    def compare_pairs
      @_compare_pairs ||= -> {
        bidi = Bidi.new

        candidates = sorted_words.zip(sorted_boxes).map do |pair|
          word, box = pair
          width = box[:lrx] - box[:ulx]

          sorted_chars = bidi.to_visual(word, paragraph_direction).chars

          sorted_chars.zip(word.chars).each_with_index.map do |chars, index|
            _, char = chars

            area = Area.new ulx: ((width / (1.0 * word.chars.count)) * index),
              lrx: ((width / (1.0 * word.chars.count)) * (index + 1)),
              uly: box[:uly],
              lry: box[:lry]

            Grapheme.new value: char,
              area: area
          end
        end

        gap = -> (word) {
          -1 * word.count
        }

        needleman_wunsch(sorted_source_words, candidates, gap_penalty: gap) do |left, right|
          -1 * levenshtein(left, right)
        end
      }.call
    end

    # Thank you wikibooks :)
    # https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Ruby
    def levenshtein(first, second)
      matrix = [(0..first.length).to_a]
      (1..second.length).each do |j|
        matrix << [j] + [0] * (first.length)
      end

      (1..second.length).each do |i|
        (1..first.length).each do |j|
          if first[j-1] == second[i-1]
            matrix[i][j] = matrix[i-1][j-1]
          else
            matrix[i][j] = [
              matrix[i-1][j],
              matrix[i][j-1],
              matrix[i-1][j-1],
            ].min + 1
          end
        end
      end
      return matrix.last.last
    end

    def paragraph_direction
      @_paragraph_direction ||= source_graphemes.first.value.codepoints.first == 0x200f ? :rtl : :ltr
    end

    def is_rtl
      paragraph_direction == :rtl
    end

    def source_graphemes
      @_source_graphemes ||= Grapheme.where(id: grapheme_ids).to_a
    end

    def sorted_source_words
      @_sorted_source_words ||= -> {
        # each line starts with the directionality grapheme
        # and may end with the pop directionality:

        graphemes = source_graphemes.each_with_index.select do |grapheme, index|
          index != 0 && !( grapheme.value != 0x202c && index != source_graphemes.count - 1 )
        end.map(&:first)

        init_state = OpenStruct.new({
          result: [ ],
          last_lrx: nil
        })

        graphemes.sort_by { |g| g.area.ulx }.inject(init_state) do |state, grapheme|
          if state.last_lrx.nil? || grapheme.area.ulx > state.last_lrx
            state.result.push([ grapheme ])
          else
            state.result[ state.result.count - 1 ].push(grapheme)
          end

          state.last_lrx = grapheme.area.lrx
          state
        end.result.each do |word|
          word.sort_by(&:position_weight)
        end
      }.call
    end

    def sorted_words
      @_sorted_words ||= is_rtl ? words.reverse : words
    end

    def sorted_boxes
      @_sorted_boxes ||= boxes.sort_by { |box| box[:ulx] }.map do |box|
        {
          ulx: box[:ulx].to_f,
          uly: box[:uly].to_f,
          lrx: box[:lrx].to_f,
          lry: box[:lry].to_f
        }
      end
    end

    def words
      @_words ||= text.split(/\s+/)
    end

    def box_for_each_word
      if words.count != boxes.count
        errors.add(:boxes, "must match in count (#{ boxes.count }) with the number of words in text (#{ words.count })")
      end
    end
  end
end
