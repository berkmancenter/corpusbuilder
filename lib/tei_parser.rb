##
# Parser for the TEI format that is able to work on the XML strings
# as well as their streams. It doesn't parse all the contents into
# a DOM graph held in memory, but rather presents lazy enumerators
# to elements produced on the fly, without any accumulation.
class TeiParser < Parser
  attr_accessor :element_parser, :tei_string, :yielder

  def self.parse(tei_string)
    new(tei_string.gsub(/\<\?.*$/, ''))
  end

  def elements
    enumerator.lazy
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
    parser = TeiElementParser.new(yielder)

    Nokogiri::XML::SAX::Parser.new(parser).
      parse(@tei_string)
  end

  class TeiElementParser < Nokogiri::XML::SAX::Document

    def initialize(yielder)
      @yielder = yielder
    end

    def start_element(name, attrs = [])
      case name
      when "surface"
        area = area_from_attributes(attrs)
        @yielder << Parser::Element.new(area: area, name: "surface")
      when "zone"
        type = type_from_attributes(attrs)
        case type
        when "segment"
          area = area_from_attributes(attrs)
          @yielder << Parser::Element.new(area: area, name: "zone")
        when "grapheme"
          # we're only storing the area for future encounter of the real grapheme
          # node - <g>
          @_last_area = area_from_attributes(attrs)
          @_in_zone_grapheme = true
        end
      when "g"
        # we're doing nothing here since we want to grab the string representation
        # that is inside of the tyag we're in now - we'll get it inside the #characters
        # method
        @_in_g = true
      when "certainty"
        if @_in_zone_grapheme
          @_last_grapheme.certainty = certainty_from_attributes(attrs)
          @yielder << @_last_grapheme
        end
      else
        # no-op
      end
    end

    def end_element(name)
      case name
      when "g"
        @_in_g = false
      when "zone"
        @_in_zone_grapheme = false
      end
    end

    def area_from_attributes(attrs)
      Area.new(attrs.inject({}) do |sum, attr|
        sum[attr.first.to_sym] = attr.last
        sum
      end)
    end

    def type_from_attributes(attrs)
      attrs.find do |pair|
        pair.first == "type"
      end.try(&:last)
    end

    def certainty_from_attributes(attrs)
      attrs.find do |pair|
        pair.first == "degree"
      end.try(&:last).try(&:to_f)
    end

    def characters(string)
      return if !@_in_g

      @_last_grapheme = Parser::Element.new(area: @_last_area, value: string, name: "grapheme")
    end
  end
end
