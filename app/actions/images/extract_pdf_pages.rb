module Images

  # Extracts individual pages into single PNG files
  class ExtractPdfPages < Action::Base
    attr_accessor :file, :name

    def execute
      pdf.each_with_index.map do |page, ix|
        filename = Rails.root.join "tmp", "#{File.basename(name, ".*")}-#{ix + 1}.png"

        page.save filename.to_s

        File.new filename
      end
    end

    def pdf
      memoized do
        Grim.reap file.path
      end
    end
  end
end

