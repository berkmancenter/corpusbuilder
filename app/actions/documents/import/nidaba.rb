module Documents
  class Import::Nidaba < Import::Base
    def image_paths_glob
      "*rgb*any_to_png*nlbin*.png"
    end

    def metadata
      memoized do
        path = Dir.glob(File.join(working_path, "metadata*.yaml*")).first

        YAML.load(File.read(path))
      end
    end

    def elements_for(image)
      # we need to output the same kinds of elements that
      # we're outputting in the HocrParser.
      # This means that we have the following list of element
      # classes: surface, zone, grapheme, all of which are
      # instance of Parser::Element

      path = image.processed_image.file.file

      image_width, image_height = \
        `file #{path}`[/\d+ x \d+/].split('x').map(&:strip).map(&:to_i)

     #file_image = MiniMagick::Image.open(image.processed_image.file.file)
     #image_width = file_image.width
     #image_height = file_image.height

      Enumerator::Lazy.new([0]) do |result, _|
        time "elements_for #{image.id}" do
        result << Parser::Element.new(
          name: "surface",
          area: Area.new(
            ulx: 0,
            uly: 0,
            lrx: image_width,
            lry: image_height
          )
        )

        entries = parsed_csv_entries(image)

        if entries.count == 0
          all_word_areas(image).each do |area|
            height = area.height
            num_chars_approx = (area.width / height).floor

            result << Parser::Element.new(
              name: "zone",
              area: area
            )

            num_chars_approx.times.each do |ix|
              result << Parser::Element.new(
                name: "grapheme",
                area: area.slice(ix, num_chars_approx),
                certainty: 0,
                value: '█',
                grouping: ix.to_s
              )
            end
          end
        else
          entries.each do |entry|
            # each line here is a new line / zone

            result << Parser::Element.new(
              name: "zone",
              area: entry.area
            )

            direction = Bidi.infer_direction entry.text
            text_words = entry.visual_text.split(/ /)

            text_words.each_with_index.each do |visual_word, word_ix|
              logical_word = Bidi.to_logical visual_word, direction
              visual_indices = Bidi.to_visual_indices(logical_word, direction)

              visual_indices.each_with_index.each do |visual_index, logical_index|
                area = grapheme_area(image, entry, word_ix, text_words.count, visual_index, logical_word.length)
                character = logical_word[ logical_index ]

                result << Parser::Element.new(
                  name: "grapheme",
                  area: area,
                  certainty: 0,
                  value: character,
                  grouping: visual_word
                )
              end
            end
          end
        end
      end
      end
    end

    def grapheme_area(image, parsed_entry, word_ix, word_count, character_ix, character_count)
      area = word_area(image, parsed_entry, word_ix, word_count, character_count)

      area.slice(character_ix, character_count)
    end

    def word_area(image, parsed_entry, word_ix, word_count, character_count)
      areas = word_areas_for(image, parsed_entry)

      if areas.count == word_count
        areas[ word_ix ]
      else
        # we need to split the area arbitrarily and let the users
        # draw better boxes:

        normed_width = parsed_entry.area.width * 1.0 / parsed_entry.text.codepoints.count
        seen_spaces = 0
        chars_before = 0

        parsed_entry.visual_text.chars.each_with_index do |char, ix|
          if seen_spaces == word_ix
            break
          end
          if !char[/\s/].nil?
            seen_spaces += 1
          end
          chars_before += 1
        end

        base = Area.span_boxes(areas)

        Area.new(
          ulx: (base.ulx + normed_width * chars_before),
          lrx: (base.ulx + normed_width * (chars_before + character_count)),
          uly: base.uly,
          lry: base.lry
        ).normalize!
      end
    end

    def word_areas_for(image, parsed_entry)
      all_word_areas(image).select do |area|
        parsed_entry.area.include? area
      end
    end

    def all_word_areas(image)
      # todo: allow memoized be indexed by arbitrary hashable
      @_all_word_areas ||= {}
      @_all_word_areas[ image.id ] ||= -> {
        doc = Nokogiri::XML(IO.read(segmentation_xml_path(image)))

        doc.css('zone[type=segment]').map do |segment|
          ulx, lrx, uly, lry = ['ulx', 'lrx', 'uly', 'lry'].map do |at|
            segment.attr(at).to_i
          end

          Area.new ulx: ulx, lrx: lrx, uly: uly, lry: lry
        end
      }.call
    end

    def segmentation_xml_path(image)
      File.join working_path, image.name.gsub(/\.png/, "_segment_tesseract.xml")
    end

    def parsed_csv_entries(image)
      all_parsed_csv_entries.select do |entry|
        image.processed_image.file.file[entry.image_path.basename.to_s].present?
      end
    end

    def all_parsed_csv_entries
      memoized do
        options = {
          headers: :first_row,
          return_headers: false
        }

        area_ix = 11
        image_path_ix = 12
        text_ix = 13
        entries = []

        CSV.foreach File.join(working_path, "data.csv"), options do |line|
          ulx, uly, lrx, lry = line[ area_ix ].gsub(/\[|\]/, '').split(',').map(&:to_i)

          area = Area.new ulx: ulx, lrx: lrx, uly: uly, lry: lry
          image_path = Pathname.new(line[ image_path_ix ])
          text = (line[ text_ix ] || "").strip

          entries << ParsedCsvEntry.new(area, text, image_path)
        end

        entries
      end
    end

    class ParsedCsvEntry
      attr_accessor :area, :text, :image_path

      def initialize(area, text, image_path)
        @area = area
        @text = text.gsub(/\s+/, ' ')
        @image_path = image_path
      end

      def direction
        @_direction ||= -> {
          Bidi.infer_direction @text
        }.call
      end

      def visual_text
        @_visual_text ||= -> {
          Bidi.to_visual @text, direction
        }.call
      end
    end
  end
end
