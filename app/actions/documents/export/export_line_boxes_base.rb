module Documents::Export
  class ExportLineBoxesBase < Action::Base
    attr_accessor :zone, :document, :dir_path

    def execute
      out_path.tap { IO.write out_path, text }.tap { after }
    end

    def after
    end

    def out_path
      File.join dir_path, "#{zone.id}.gt.txt"
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


