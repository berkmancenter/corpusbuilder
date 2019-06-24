require 'securerandom'

module Images

  # Extracts individual pages into single PNG files
  class ExtractPdfPages < Action::Base
    attr_accessor :file, :name

    def execute
      basedir = Rails.root.join "tmp", (sanitized_name + SecureRandom.uuid)

      basedir.mkpath

      #command = "pdfimages -p -png '#{file.path}' '#{basedir}'"
      command = "gs -q -dNOPAUSE -sDEVICE=png256 -r300 -sOutputFile='#{basedir}/#{Pathname.new(file.path).basename}-%07d.png' '#{file.path}' -c quit"

      Rails.logger.info "Extracting images from PDF with: #{command}"

      `#{command}`

      Dir[basedir.to_s + "/*"].sort.select do |path|
        ImageHelper.image_area(image_path: path).width > 100
      end.tap do |paths|
        Rails.logger.info "Extracted #{paths.count} pages"
      end
    end

    def sanitized_name
      name.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "�").
        strip.
        tr("\u{202E}%$|:;/\t\r\n\\", "-")
    end
  end
end

