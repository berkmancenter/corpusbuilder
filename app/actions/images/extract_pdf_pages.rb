require 'securerandom'

module Images

  # Extracts individual pages into single PNG files
  class ExtractPdfPages < Action::Base
    attr_accessor :file, :name

    def execute
      basedir = Rails.root.join "tmp", (sanitized_name + SecureRandom.uuid)

      `pdfimages -png '#{file.path}' '#{basedir}'`

      Dir[basedir.to_s + "*"].map do |path|
        File.new path
      end
    end

    def sanitized_name
      name.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "�").
        strip.
        tr("\u{202E}%$|:;/\t\r\n\\", "-")
    end
  end
end

