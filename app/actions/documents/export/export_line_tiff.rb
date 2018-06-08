module Documents::Export
  class ExportLineTiff < Action::Base
    attr_accessor :zone, :document, :dir_path, :image

    def execute
      imported_from_png.write out_path
    end

    def out_path
      File.join dir_path, "#{zone.id}.tif"
    end

    def imported_from_png
      memoized do
        MiniMagick::Image.read(
          cropped_png.to_blob(:fast_rgb)
        ).mogrify do |builder|
          # adding 15 pixels around the line image
          # because tesseract
          builder.send('bordercolor', 'white')
          builder.send('border', 15)
        end
      end
    end

    def cropped_png
      memoized do
        ExportLinePng.run!(
          zone: zone,
          document: document,
          dir_path: dir_path,
          image: image,
          save: false
        ).result
      end
    end
  end
end

