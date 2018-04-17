module Documents
  class CompileCorrections < Action::Base
    attr_accessor :words, :document, :revision_id, :branch_name, :surface_number, :dir

    validate :revision_given

    def execute
      line_diff.specs
    end

    def revision
      memoized do
        if !branch_name.nil?
          rev = Revision.working.where(
            parent_id: document.branches.where(name: branch_name).select("branches.revision_id")
          ).first
          if rev.nil?
            nil
          end
          rev
        else
          Revision.find(revision_id)
        end
      end
    end

    def line_diff
      memoized do
        LineDiff.new(words, revision, surface_number, dir)
      end
    end

    class CorrectionDiff
      include Memoizable

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
        return true if from.conflict? || to.conflict?

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
      attr_accessor :words, :revision, :surface_number, :dir

      def initialize(words, revision, surface_number, dir)
        @words = words
        @revision = revision
        @surface_number = surface_number
        @dir = dir
      end

      def specs
        memoized do
          if deleting_line?
            return source_graphemes.map do |grapheme|
              GraphemeDiff.new(grapheme, nil, nil).to_spec
            end
          end

          if directionality_change?
            ds = source_graphemes.map do |grapheme|
              GraphemeDiff.new(grapheme, nil, nil).to_spec
            end
            ds += entered_graphemes.map do |grapheme|
              GraphemeDiff.new(nil, grapheme, WordDiff.new(nil, grapheme, self), true).to_spec
            end

            return ds
          end

          source_list = source_graphemes.dup
          entered_list = entered_graphemes.dup

          all_diffs = word_diffs.map(&:grapheme_diffs).flatten

          diffs = all_diffs.reject(&:deletion?).group_by do |grapheme_diff|
            grapheme_diff.entered.id
          end

          initial_state = OpenStruct.new({ result: [ ], current_span: nil, previous: nil })

          diff_spans = if new_line? or deleting_line?
            [
              OpenStruct.new({
                open: nil,
                close: nil,
                diffs: diffs.values.flatten
              })
            ]
          else
            run = entered_list.inject(initial_state) do |state, grapheme|
              if diffs.has_key?(grapheme.id)
                state.current_span ||= OpenStruct.new({ open: nil, close: nil, diffs: [ ] })
                state.current_span.open ||= source_list.find do |g|
                  state.previous.present? && !graphemes_need_change(g, state.previous)
                end
                state.current_span.diffs.push(diffs[ grapheme.id ].first)
              else
                if state.current_span.present?
                  state.current_span.close = source_list.find do |g|
                    !graphemes_need_change(g, grapheme)
                  end
                  state.result.push(state.current_span)
                  state.current_span = nil
                end
              end

              state.previous = grapheme

              state
            end

            run.result.push(run.current_span).reject(&:nil?)
          end

          diff_spans.map do |diff_span|
            grapheme_diffs = diff_span.diffs.sort_by { |diff| diff.entered.position_weight }

            addmod_specs = grapheme_diffs.map(&:to_spec)

            open_position_weight = diff_span.open.try(:position_weight) || -> {
              (source_graphemes.first.try(:position_weight) || 0) - diff_span.diffs.count - 1
            }.call

            close_position_weight = diff_span.close.try(:position_weight) || -> {
              (source_graphemes.last.try(:position_weight) || 0) + diff_span.diffs.count + 1
            }.call

            addmod_specs.each_with_index do |addmod_spec, index|
              addmod_spec[:position_weight] = open_position_weight +
                ( index + 1 ) * (
                  ( close_position_weight - open_position_weight ) /
                  ( grapheme_diffs.count + 1.0 )
                )
            end

            addmod_specs
          end.flatten + all_diffs.select(&:deletion?).map(&:to_spec)
        end
      end

      def new_line?
        source_graphemes.empty?
      end

      def deleting_line?
        words.all? { |word| word[:text].strip.empty? }
      end

      def directionality_change?
        if source_graphemes.empty? || dir.nil?
          false
        else
          source_graphemes.first.zone.direction != dir.to_s
        end
      end

      def word_diffs
        all_word_diffs.select(&:differ?)
      end

      def all_word_diffs
        memoized do
          gap = -> (word) {
            -1 * word.count
          }

          alignments = needleman_wunsch(visually_sorted_source_words, visually_sorted_entered_words,
                                        gap_penalty: gap) do |left, right|
            if (left.any?(&:conflict?) || right.any?(&:conflict?)) && left.text == right.text
              0
            elsif left.any?(&:conflict?) || right.any?(&:conflict?) || left.count != right.count
              -1 * [ left.count, right.count ].max
            elsif left.zip(right).any? { |l, r| graphemes_need_change(l, r) }
              -1 * levenshtein(left.text, right.text)
            else
              left.count
            end
          end

          alignments.first.zip(alignments.last).map do |source, entered|
            WordDiff.new(source, entered, self)
          end
        end
      end

      def source_words
        memoized do
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
        end
      end

      def visually_sorted_source_words
        source_words.sort_by { |word| word.area.ulx }
      end

      def visual_entered_text
        sorted_words = @words.sort_by { |word| word[:area][:ulx].to_f }
        sorted_words.map { |word| word[:text] }.join(' ')
      end

      def entered_words
        memoized do
          last_position = 0

          sorted_words = @words.sort_by { |word| word[:area][:ulx].to_f }
          visual_text = sorted_words.map { |word| word[:text] }.join(' ')

          vis2word = sorted_words.each_with_index.map do |word, ix|
            [[ix] * word[:text].codepoints.count, nil]
          end.flatten
          logical_indices = Bidi.to_logical_indices(visual_text, ltr? ? :ltr : :rtl)
          logical_words = logical_indices.each_with_index.map do |lix, vix|
            { lix: lix, word: sorted_words[ vis2word[ vix ] ] } if vis2word[ vix ].present?
          end.reject(&:nil?).sort_by { |w| w[:lix] }.map { |w| w[:word] }.uniq

          logical_words.each_with_index.map do |word, logical_index|
            entered_chars = EnteredChar.from_word(word[:text], ltr? ? :ltr : :rtl)

            sorted_visually = entered_chars.sort_by(&:visual_index)

            graphemes = sorted_visually.each_with_index.map do |entered_char, local_index|
              box = normalize_area(word[:area])
              width = box[:lrx] - box[:ulx]
              delta_x = ((width / (1.0 * entered_chars.count)) * local_index)
              delta_x_end = ((width / (1.0 * entered_chars.count)) * (local_index + 1))

              area = Area.new ulx: box[:ulx] + delta_x,
                lrx: box[:ulx] + delta_x_end,
                uly: box[:uly],
                lry: box[:lry]

              Grapheme.new value: entered_char.char,
                area: area,
                zone_id: zone_id,
                position_weight: last_position + entered_char.index,
                id: SecureRandom.uuid
            end

            last_position = graphemes.map(&:position_weight).max + 1

            Word.new(graphemes)
          end
        end
      end

      def zone_id
        zone.id
      end

      def zone
        memoized do
          if source_graphemes.empty?
            area = Area.span_boxes(words.map { |word| word[:area] }).normalize!

            zone_ids_query = revision.
              graphemes.
              joins(zone: :surface).
              where(zones: { surfaces: { number: surface_number } }).
              where('zones.position_weight is not null').
              select(:zone_id)

            zones = Zone.where(id: zone_ids_query)

            initial = OpenStruct.new({
              clusters: [],
              current_max_ulx: 0,
              current_min_lrx: 10e10
            })

            clusters = zones.reduce(initial) do |state, line|
              inter_ulx = [ state.current_max_ulx, line.area.ulx ].max
              inter_lrx = [ state.current_min_lrx, line.area.lrx ].min

              mean_cluster_ulx = state.clusters.count > 0 ?
                state.clusters[ state.clusters.count - 1 ].map(&:area).map(&:ulx).mean :
                0
              mean_cluster_lrx = state.clusters.count > 0 ?
                state.clusters[ state.clusters.count - 1 ].map(&:area).map(&:lrx).mean :
                0

              mean_cluster_width = mean_cluster_lrx - mean_cluster_ulx
              line_width = line.area.lrx - line.area.ulx

              if state.clusters.empty? ||
                  line.area.ulx > state.current_min_lrx ||
                  line.area.lrx < state.current_max_ulx ||
                  (inter_lrx - inter_ulx) < 0.5*mean_cluster_width ||
                  line_width < 0.5*mean_cluster_width ||
                  line_width > 1.5*mean_cluster_width
                state.clusters.push([ line ])
                state.current_max_ulx = line.area.ulx
                state.current_min_lrx = line.area.lrx
              else
                state.clusters[ state.clusters.count - 1 ].push(line)
                state.current_max_ulx = inter_ulx
                state.current_min_lrx = inter_lrx
              end

              state
            end.clusters.map do |cluster|
              OpenStruct.new({
                lines: cluster,
                area: Area.span_boxes(cluster.map(&:area))
              })
            end

            previous_weight = 0
            next_weight = 0

            our_cluster = clusters.find do |cluster|
              cluster.area.uly <= area.uly &&
                cluster.area.lry >= area.lry &&
                cluster.area.ulx <= area.ulx &&
                cluster.area.lrx >= area.lrx
            end

            if our_cluster.present?
              above_line = our_cluster.lines.select do |line|
                line.area.lry <= area.lry
              end.last

              if above_line.present?
                previous_weight = above_line.position_weight

                next_weight = zones.find { |zone| zone.position_weight > previous_weight }.
                  try(:position_weight) || (previous_weight + 1)
              else
                next_weight = our_cluster.lines.first.position_weight

                previous_weight = zones.find { |zone| zone.position_weight < previous_weight }.
                  try(:position_weight) || (next_weight - 1)
              end
            end

            if ltr?
              left_cluster = clusters.find do |cluster|
                cluster.area.lry >= area.uly &&
                  cluster.area.uly <= area.lry &&
                  cluster.area.lrx < area.ulx
              end

              if left_cluster.present?
                previous_weight = left_cluster.lines.last.position_weight
                next_weight = zones.find { |zone| zone.position_weight > previous_weight }.
                  try(:position_weight) || (previous_weight + 1)
              end
            else
              right_cluster = clusters.find do |cluster|
                cluster.area.lry >= area.uly &&
                  cluster.area.uly <= area.lry &&
                  cluster.area.ulx > area.lrx
              end

              if right_cluster.present?
                previous_weight = right_cluster.lines.last.position_weight
                next_weight = zones.find { |zone| zone.position_weight > previous_weight }.
                  try(:position_weight) || (previous_weight + 1)
              end
            end

            if previous_weight == 0 && next_weight == 0
              top_cluster = clusters.select do |cluster|
                cluster.area.uly < area.uly
              end.last

              if top_cluster.present?
                previous_weight = top_cluster.lines.last.position_weight
                next_weight = zones.find { |zone| zone.position_weight > previous_weight }.
                  try(:position_weight) || (previous_weight + 1)
              else
                next_weight = clusters.first.lines.first.position_weight

                previous_weight = zones.find { |zone| zone.position_weight < previous_weight }.
                  try(:position_weight) || (next_weight - 1)
              end
            end

            Zone.create! surface_id: revision.document.surfaces.where(number: surface_number).first.id,
              area: area,
              direction: Bidi.infer_direction( visual_entered_text ),
              position_weight: (previous_weight + 0.5*(next_weight - previous_weight))
          else
            old = source_graphemes.first.zone

            if directionality_change?
              Zone.create! surface_id: old.surface_id,
                area: old.area,
                direction: dir,
                position_weight: old.position_weight
            else
              old
            end
          end
        end
      end

      def visually_sorted_entered_words
        entered_words.sort_by { |word| word.area.ulx }
      end

      def normalize_area(box)
        {
          ulx: (box[:ulx] || box["ulx"]).to_f.round,
          uly: (box[:uly] || box["uly"]).to_f.round,
          lrx: (box[:lrx] || box["lrx"]).to_f.round,
          lry: (box[:lry] || box["lry"]).to_f.round
        }
      end

      def source_graphemes_filtered
        memoized do
          source_graphemes.select do |grapheme|
            codepoint = grapheme.value.codepoints.first
            codepoint != 0x202c && codepoint != 0x200f && codepoint != 0x200e
          end
        end
      end

      def rtl?
        !ltr?
      end

      def ltr?
        memoized do
          if dir.present?
            dir == :ltr
          else
            if new_line?
              Bidi.infer_direction(visual_entered_text) == :ltr
            else
              zone.ltr?
            end
          end
        end
      end

      def grapheme_ids
        memoized do
          words.map { |word| word[:grapheme_ids] }.flatten
        end
      end

      def source_graphemes
        memoized do
          Grapheme.where(id: grapheme_ids).to_a
        end
      end

      def entered_graphemes
        memoized do
          entered_words.map do |entered_word|
            entered_word.graphemes
          end.flatten.sort_by { |g| g.position_weight }
        end
      end

      class EnteredChar
        attr_accessor :char, :index, :visual_index

        def initialize(char, index, visual_index)
          @char = char
          @index = index
          @visual_index = visual_index
        end

        def self.from_word(text_word, dir)
          indices = Bidi.to_visual_indices(text_word, dir)

          indices.each_with_index.map do |logical_index, visual_index|
            EnteredChar.new(text_word[logical_index], logical_index, visual_index)
          end
        end
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
        memoized do
          source_alignment, entered_alignment = needleman_wunsch(source, entered,
                                                                 gap_penalty: -1) do |left, right|
            graphemes_need_change(left, right) ? -1 : 1
          end

          source_alignment.zip(entered_alignment).map do |from, to|
            GraphemeDiff.new(from, to, self)
          end.select(&:differ?)
        end
      end

      def differ?
        source.nil? && entered.present? ||
          source.present? && entered.nil? ||
          source != entered
      end

      def inspect
        "<WordDiff source: #{ @source.inspect } entered: #{ @entered.inspect }>"
      end
    end

    class GraphemeDiff < CorrectionDiff
      attr_accessor :source, :entered, :word_diff, :override_weights

      def initialize(source, entered, word_diff, override_weights = false)
        @source = source
        @entered = entered
        @word_diff = word_diff
        @override_weights = override_weights
      end

      def to_spec
        if addition?
          {
            value: entered.value,
            area: entered.area,
            zone_id: entered.zone_id,
            surface_number: word_diff.line_diff.surface_number,
            position_weight: (override_weights ? entered.position_weight : nil)
          }
        elsif deletion?
          {
            id: source.id,
            delete: true
          }
        elsif modification? || merge_resolution?
          {
            id: source.id,
            position_weight: (override_weights ? entered.position_weight : nil),
            value: entered.value,
            zone_id: entered.zone_id,
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
        addition? || deletion? || modification? || merge_resolution?
      end

      def merge_resolution?
        source.present? && entered.present? &&
          (source.conflict? || entered.conflict?)
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

    class Word
      include Enumerable
      include Memoizable

      attr_accessor :graphemes

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
        memoized do
          @graphemes.sort_by(&:position_weight)
        end
      end

      def visually_ordered
        memoized do
          @graphemes.sort_by { |g| g.area.ulx }
        end
      end

      def text
        logically_ordered.map(&:value).join('')
      end

      def has_new?
        logically_ordered.any? { |g| !g.persisted? }
      end

      def ==(other)
        other.nil? || (
          text == other.text &&
          area == other.area &&
          @graphemes.none?(&:conflict?) && other.none?(&:conflict?)
        )
      end

      def area
        memoized do
          areas = visually_ordered.map(&:area)
          Area.new(
            ulx: areas.map(&:ulx).min,
            uly: areas.map(&:uly).min,
            lrx: areas.map(&:lrx).max,
            lry: areas.map(&:lry).max
          )
        end
      end

      def inspect
        "<Word #{ has_new? ? '=N=' : '' } text: \"#{ text }\" area: #{ area }>"
      end
    end

    def create_development_dumps?
      true
    end

    def revision_given
      if revision.nil?
        errors.add(:base, "Given branch name or revision id doesn't point at any existing revision")
      end
    end
  end
end
