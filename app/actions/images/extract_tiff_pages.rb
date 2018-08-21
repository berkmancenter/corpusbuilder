module Images

  # Extracts individual pages into single PNG files
  class ExtractTiffPages < Action::Base
    attr_accessor :file, :name

    def execute
      results = []

      Tiff::Image.open(file.path, "r") do |tiff_file|
        if tiff_file.pages.count > 1
          tiff_file.pages.each_with_index do |page, ix|
            png = ChunkyPNG::Image.new(page.width, page.height)

            for x in 1..page.width
              for y in 1..page.height
                pixel = page[ x - 1, page.height - y ]
                png[ x - 1, y - 1 ] = ChunkyPNG::Color.rgb(pixel.r, pixel.g, pixel.b)
              end
            end

            temp_file = File.new(Rails.root.join("tmp", "#{name}-#{ix}.png"), "w", :encoding => 'ascii-8bit')

            time "writing PNG" do
              png.write temp_file, {
                color_mode: ChunkyPNG::COLOR_GRAYSCALE,
                interlace: false,
                compression: 9
              }
            end

            results << temp_file
          end
        else
          results << file
        end
      end

      results
    end
  end
end
