module Documents::Export
  class ExportLineBoxesKraken < ExportLineBoxesBase
    attr_accessor :zone, :document, :dir_path

    def text
      words.map do |word_graphemes|
        word_graphemes.map(&:value).join ''
      end.join ' '
    end
  end
end

