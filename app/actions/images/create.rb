module Images
  class Create < Action::Base
    attr_accessor :file, :name

    def execute
      if tiff?
        tiff_page_files.map do |page_file|
          Image.create! image_scan: page_file,
            name: name
        end
      else
        [
          Image.create!(
            image_scan: file,
            name: name
          )
        ]
      end
    end

    def tiff?
      false # todo: implement me
    end

    def tiff_page_files
      memoized do
        Images::ExtractTiffPages.run!(
          file: file,
          name: name
        )
      end
    end
  end
end
