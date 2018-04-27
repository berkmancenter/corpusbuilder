require 'securerandom'
require 'progressbar/memory_formatter'

module Documents::Export
  class Dataset < Action::Base
    attr_accessor :document, :image_format, :boxes_format, :show_cli_progress, :print_mem_usage

    def execute
      extract_zones
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
        relative = Pathname.new(extract_path).relative_path_from(Rails.root)
        memory = print_mem_usage ? ' :memory' : ''
        bar = TTY::ProgressBar.new(
          "Extracting dataset (#{ relative }) - :current/:total :percent :rate/s ( mean :mean_rate/s ) [:bar] :eta#{ memory }",
          total: zones.count
        )
        bar.use MemoryFormatter if print_mem_usage
        bar
      end
    end

    def extract_zones
      last_surface_id = nil
      image = nil

      zones.each_with_index do |zone, ix|
        if zone.surface_id != last_surface_id
          image = surface_image(zone)
          GC.start
        end

        extract_line(zone, image).tap do |_|
          if show_cli_progress
            progressbar.log("Current surface number: #{zone.surface.number}") if zone.surface_id != last_surface_id
            progressbar.advance(1)
          end
        end

        last_surface_id = zone.surface_id
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
