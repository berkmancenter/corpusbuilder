class ImageHelper
  class << self
    def image_area(image_path:)
      w, h = `file #{image_path}`[/\d+ x \d+/].split('x').map(&:strip).map(&:to_i)

      Area.new ulx: 0, lrx: w, uly: 0, lry: h
    end
  end
end
