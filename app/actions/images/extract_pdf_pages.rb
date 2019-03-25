require 'securerandom'

module Images

  # Extracts individual pages into single PNG files
  class ExtractPdfPages < Action::Base
    attr_accessor :file, :name

    def execute
      basedir = Rails.root.join "tmp", name, SecureRandom.uuid

      `pdfimages -png #{file.path} #{basedir}`

      Dir[basedir.to_s + "*"].map do |path|
        File.new path
      end
    end

    def pdf
      memoized do
        Grim.reap file.path
      end
    end
  end
end

