module Documents
  class Import::KrakenExported < Import::Nidaba
    def image_paths_glob
      "*.png"
    end

    def metadata
      memoized do
        {
          title: archive_path.
            split('.').
            reverse.
            drop(1).
            reverse.
            join('.').
            split('/').
            last
        }
      end
    end

    def parsed_csv_entries(image)
      file_image = MiniMagick::Image.open(image.processed_image.file.file)
      image_width = file_image.width
      image_height = file_image.height

      area = Area.new \
        ulx: 0,
        lrx: image_width,
        uly: 0,
        lry: image_height

      image_path = Pathname.new(image.processed_image.file.file)
      txt_path = Pathname.new(working_path).
        join(image.name.split('.').reverse.drop(1).reverse.join('.') + '.gt.txt')

      text = File.read(txt_path)

      [ ParsedCsvEntry.new(area, text, image_path) ]
    end

    def all_word_areas(image)
      @_all_word_areas ||= {}
      @_all_word_areas[ image.id ] ||= -> {
        file_image = MiniMagick::Image.open(image.processed_image.file.file)
        image_width = file_image.width
        image_height = file_image.height

        [ Area.new(ulx: 0, lrx: image_width, uly: 0, lry: image_height) ]
      }.call
    end

  end
end
