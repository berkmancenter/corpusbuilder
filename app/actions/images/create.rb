module Images
  class Create < Action::Base
    attr_accessor :file_id, :name

    def execute
      images = page_files.map do |page_file|
        Image.create! image_scan: File.new(page_file),
          name: File.basename(page_file)
      end.to_a

      Image::Short.represent images
    end

    def tiff?
      attachment.content_type == "image/tiff"
    end

    def pdf?
      attachment.content_type == "application/pdf"
    end

    def attachment
      file.attachment.file
    end

    def file
      memoized do
        StashedFile.find file_id
      end
    end

    def page_files
      memoized do
        if tiff?
          Images::ExtractTiffPages.run!(
            file: attachment,
            name: name
          ).result
        elsif pdf?
          Images::ExtractPdfPages.run!(
            file: attachment,
            name: name
          ).result
        else
          [ attachment.path ]
        end
      end
    end
  end
end
