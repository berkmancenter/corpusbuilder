module Documents::Export
  class ExportLineBoxesKraken < Action::Base
    attr_accessor :zone, :document, :dir_path

    def execute
      out_path.tap { IO.write out_path, text }
    end

    def out_path
      File.join dir_path, "#{zone.id}.gt.txt"
    end

    def text
      words.map do |word_graphemes|
        word_graphemes.map(&:value).join ''
      end.join ' '
    end

    def words
      memoized freeze: true do
        Graphemes::GroupWords.run!(graphemes: graphemes).result
      end
    end

    def graphemes
      memoized do
        Graphemes::QueryLine.run!(
          zone: zone,
          document: document,
          revision: document.master.revision
        ).result
      end
    end
  end
end

