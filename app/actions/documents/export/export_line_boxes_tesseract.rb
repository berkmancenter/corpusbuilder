module Documents::Export
  class ExportLineBoxesTesseract < ExportLineBoxesBase
    attr_accessor :zone, :document, :dir_path

    def text
      init_state = OpenStruct.new(
        lines: [ ],
        last_line_box: nil
      )

      words.inject(init_state) do |state, graphemes|
        line_box = Area.span_boxes graphemes.map(&:area)
        line_box_text = box_to_text(line_box)

        if state.last_line_box.present?
          separator_box = Area.new(
            ulx: state.last_line_box.ulx,
            lrx: state.last_line_box.ulx + 1,
            uly: state.last_line_box.uly + 1,
            lry: state.last_line_box.lry + 2
          )
          state.lines << " #{box_to_text(separator_box)} 0"
        end

        for grapheme in graphemes
          state.lines << "#{ grapheme.value } #{line_box_text} 0"
        end

        state.last_line_box = line_box
        state
      end.lines.join("\n")
    end

    def after
      Documents::Export::ExportUnicharsetTesseract.run! dir_path: dir_path
    end

    def box_to_text(box)
      left = 0
      bottom = 0
      right = box.width
      top = box.height

      [ left, bottom, right, top ].join ' '
    end
  end
end


