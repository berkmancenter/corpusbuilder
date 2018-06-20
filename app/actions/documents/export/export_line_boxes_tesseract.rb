module Documents::Export
  class ExportLineBoxesTesseract < ExportLineBoxesBase
    attr_accessor :zone, :document, :dir_path

    def text
      init_state = OpenStruct.new(
        lines: [ ],
        last_word_box: nil
      )

      run = visually_sorted_words.inject(init_state) do |state, graphemes|
        word_box = Area.span_boxes graphemes.map(&:area)

        if !state.lines.empty?
          separator_box = Area.new(
            ulx: state.last_word_box.ulx + 1,
            lrx: state.last_word_box.ulx + 2,
            uly: state.last_word_box.uly,
            lry: state.last_word_box.lry
          )
          state.lines << "  #{box_to_text(separator_box)} 0"
        end

        graphemes.each_with_index do |grapheme, index|
          state.lines << "#{ grapheme.value } #{grapheme_box_text(word_box, index, graphemes.count)} 0"
        end

        state.last_word_box = word_box
        state
      end

      lines = run.lines
      last_box = Area.new(
        ulx: line_box.lrx + 1,
        lrx: line_box.lrx + 2,
        uly: line_box.uly,
        lry: line_box.lry
      )
      lines << "\t #{box_to_text(last_box)}"
      lines << ""

      lines.join("\n")
    end

    def visually_sorted_words
      memoized do
        words.map do |graphemes|
          graphemes.sort_by { |g| g.area.ulx }
        end.sort_by { |w| w.first.area.ulx }
      end
    end

    def after
      Documents::Export::ExportUnicharsetTesseract.run! dir_path: dir_path
    end

    def extension
      "box"
    end

    def grapheme_box_text(line_box, index, count_all)
      box_to_text grapheme_box(line_box, index, count_all)
    end

    def grapheme_box(line_box, index, count_all)
      single_width = line_box.width / count_all

      Area.new ulx: (line_box.ulx + index * single_width),
        uly: line_box.uly,
        lrx: (line_box.ulx + (index + 1) * single_width),
        lry: line_box.lry
    end

    def line_box
      memoized do
        Area.span_boxes words.flatten.map(&:area)
      end
    end

    def normalize_box(box)
      Δx = line_box.ulx
      Δy = line_box.uly

      Area.new ulx: (box.ulx - Δx),
        uly: (box.uly - Δy),
        lrx: (box.lrx - Δx),
        lry: (box.lry - Δy)
    end

    def box_to_text(box)
      # moving it by (15, 15) as tesseract exported images
      # have 15 pixels border:

      normalized = normalize_box box

      # weird math stems from the tesseract coords system
      # which has the y axis backwards

      left = normalized.ulx + 15
      bottom = (line_box.height - normalized.lry) + 15
      right = normalized.lrx + 15
      top = (line_box.height - normalized.lry + normalized.height) + 15

      [ left, bottom, right, top ].join ' '
    end
  end
end


