require 'nokogiri'
include Nokogiri

##
# Parser for the TEI format that is able to work on the XML strings
# as well as their streams. It doesn't parse all the contents into
# a DOM graph held in memory, but rather presents lazy enumerators
# to elements produced on the fly, without any accumulation.
class TeiParser < Parser
  attr_accessor :element_parser, :tei_string, :yielder

  def self.parse(tei_string)
    # todo: make the following work with streams and make
    # the string case performant too
    new(tei_string.gsub(/\<\?.*$/, ''))
  end

  def surfaces
    enumerator.lazy.select do |element|
      element.is_a? SurfaceElement
    end
  end

  private

  def initialize(tei_string)
    @tei_string = tei_string
  end

  def enumerator
    @_enumerator ||= Enumerator.new do |yielder|
      init_parser(yielder)
    end
  end

  def init_parser(yielder)
    parser = TeiElementParser.new

    parser.push_yielder(yielder)

    Nokogiri::XML::SAX::Parser.new(parser).
      parse(@tei_string)
  end

  class TeiElementParser < Nokogiri::XML::SAX::Document

    def push_yielder(yielder)
      @yielders ||= []
      @yielders.push yielder
    end

    def start_element(name, attrs = [])
      case name
      when "surface"
        area = area_from_attributes(attrs)
        @yielders.last << SurfaceElement.new(area: area, parser: self)
      when "zone"
        type = type_from_attributes(attrs)
        case type
        when "segment"
          area = area_from_attributes(attrs)
          @yielders.last << ZoneElement.new(area: area, parser: self)
        when "grapheme"
          # we're only storing the area for future encounter of the real grapheme
          # node - <g>
          @_last_area = area_from_attributes(attrs)
        end
      when "g"
        # we're doing nothing here since we want to grab the string representation
        # that is inside of the tyag we're in now - we'll get it inside the #characters
        # method
      else
        # no-op
      end
    end

    def area_from_attributes(attrs)
      AreaAttr.new(attrs.inject({}) do |sum, attr|
        sum[attr.first] = attr.last
        sum
      end)
    end

    def type_from_attributes(attrs)
      attrs.find do |pair|
        pair.first == "type"
      end.try(&:last)
    end

    def characters(string)
      @yielders.last << GraphemeElement.new(area: @_last_area, value: string)
    end

    def end_element(name)
      case name
      when "surface", "zone"
        @yielders.pop
      else
      end
    end
  end

  class SurfaceElement
    attr_accessor :area, :parser

    def initialize(options)
      @area = options[:area]
      @parser = options[:parser]

      @_zones = Enumerator.new do |yielder|
        @parser.push_yielder(yielder)
      end
    end

    def zones
      @_zones.lazy.select do |element|
        element.is_a? ZoneElement
      end
    end
  end

  class ZoneElement
    attr_accessor :area, :parser

    def initialize(options)
      @area = options[:area]
      @parser = options[:parser]

      @_graphemes = Enumerator.new do |yielder|
        @parser.push_yielder(yielder)
      end
    end

    def graphemes
      @_graphemes.lazy.select do |element|
        element.is_a? GraphemeElement
      end
    end
  end

  class GraphemeElement
    attr_accessor :area, :value

    def initialize(options)
      @area = options[:area]
      @value = options[:value]
    end
  end

  class AreaAttr
    attr_accessor :lrx, :lry, :ulx, :uly

    def initialize(options)
      @lrx = options[:lrx]
      @lry = options[:lry]
      @ulx = options[:ulx]
      @uly = options[:uly]
    end
  end
end
