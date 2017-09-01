class Parser
  def self.parse(tei_xml)
    raise NotImplementedError.new
  end

  def surfaces
    raise NotImplementedError.new
  end

  class Element
    attr_accessor :area, :value, :name, :certainty

    def initialize(options)
      @area = options[:area]
      @value = options[:value]
      @name = options[:name]
      @certainty = options[:certainty]
    end
  end

  class AreaAttr
    attr_accessor :lrx, :lry, :ulx, :uly

    def initialize(options)
      @lrx = options[:lrx].to_i
      @lry = options[:lry].to_i
      @ulx = options[:ulx].to_i
      @uly = options[:uly].to_i
    end
  end
end
