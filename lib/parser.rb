class Parser
  def self.parse(tei_xml)
    raise NotImplementedError.new
  end

  def surfaces
    raise NotImplementedError.new
  end

  class Element
    attr_accessor :area, :value, :name, :certainty, :grouping

    def initialize(options)
      @area = options[:area]
      @value = options[:value]
      @name = options[:name]
      @certainty = options[:certainty]
      @grouping = options[:grouping]
    end
  end
end
