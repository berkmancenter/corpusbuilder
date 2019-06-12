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
      area = all_word_areas(image).first

      image_path = Pathname.new(image.processed_image.file.file)
      txt_path = Pathname.new(working_path).
        join(image.name.split('.').reverse.drop(1).reverse.join('.') + '.gt.txt')

      text = File.read(txt_path)

      [ ParsedCsvEntry.new(area, text, image_path) ]
    end

    def all_word_areas(image)
      @_all_word_areas ||= {}
      @_all_word_areas[ image.id ] ||= -> {
        path = image.processed_image.file.file

        w, h = `file #{path}`[/\d+ x \d+/].split('x').map(&:strip).map(&:to_i)

        [ Area.new(ulx: 0, lrx: w, uly: 0, lry: h) ]
      }.call
    end

  end
end
