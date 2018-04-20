require 'securerandom'

module Documents::Export
  class Dataset < Action::Base
    attr_accessor :document, :image_format, :boxes_format, :show_cli_progress

    def execute
      {
        dir: extract_path,
        zones: extracted_zones
      }
    end

    def extract_path
      memoized do
        dir_name = "#{DateTime.now.to_i}-#{document.id}-#{image_format}-#{boxes_format}"
        File.join(Rails.root, "public", "export", dir_name).tap do |path|
          Dir.mkdir path
        end
      end
    end

    def progressbar
      memoized do
        TTY::ProgressBar.new("Extracting dataset (#{ extract_path }) - :percent [:bar] :eta", total: zones.count)
      end
    end

    def extracted_zones
      last_surface_id = nil

      zones.each_with_index.map do |zone, ix|
        image = surface_image(zone) if zone.surface_id != last_surface_id

        extract_line(zone, image).tap do |_|
          if show_cli_progress
            progressbar.advance(1)
          end
        end
      end
    end

    def extract_line zone, image
      {
        image_path: image_extractor.run!(zone: zone, document: document, dir_path: extract_path, image: image),
        boxes_path: boxes_extractor.run!(zone: zone, document: document, dir_path: extract_path)
      }
    end

    def image_extractor
      case image_format
      when :png
        Documents::Export::ExportLinePng
      when :tiff
        Documents::Export::ExportLineTiff
      else
        raise ArgumentError, "#{image_format} not within the set of possible image_format values of: :png, :tiff"
      end
    end

    def boxes_extractor
      case boxes_format
      when :kraken
        Documents::Export::ExportLineBoxesKraken
      when :tesseract
        Documents::Export::ExportLineBoxesTesseract
      else
        raise ArgumentError, "#{boxes_format} not within the set of possible boxes_format values of: :kraken, :tesseract"
      end
    end

    def surface_image(zone)
      ChunkyPNG::Image.from_file(image_path(zone))
    end

    def image_path(zone)
      zone.surface.image.processed_image.path
    end

    def zones
      memoized do
        Zones::QueryMasterList.run!(document: document).result
      end
    end
  end
end
