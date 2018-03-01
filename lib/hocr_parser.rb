# Parses the string containing the hOCR classifier output.
# Doesn't work with streams as is turned out the "traditional" approach is
# sufficiently performant and didn't eat that lot of memory
class HocrParser < Parser
  attr_accessor :element_parser, :hocr_string, :yielder

  def self.parse(hocr_string)
    new(hocr_string.gsub(/\<\?.*$/, ''))
  end

  def next_level(level)
    case level
    when '.ocr_page'
      '.ocr_par'
    when '.ocr_par'
      '.ocr_line'
    when '.ocr_line'
      '.ocrx_word'
    else
      nil
    end
  end

  def elements(node = xml_page_root, directional = nil)
    node_class = attr(node, "class")

    Enumerator::Lazy.new([ 0 ]) do |yielder, _|
      to_elements(node, node_class, directional).each do |element|
        yielder << element
      end

      if node_class != 'ocrx_word'
        child_nodes = 0
        child_selector = ".#{node_class}"

        while child_nodes == 0 && child_selector != nil
          child_selector = next_level child_selector
          child_nodes = node.css(child_selector).count
        end

        node.css(child_selector).each do |child_node|
          class_name = child_node.attr('class')

          if !class_name.is_a?(String)
            class_name = class_name.value
          end

          if class_name == 'ocr_par'
            directional = to_directional_element(child_node)
          end

          elements(child_node, directional).each do |element|
            yielder << element
          end
        end if child_selector.present?
      end
    end
  end

  def attr(node, name)
    result = node.attr(name)
    result.is_a?(String) ? result : result.value
  end

  def to_directional_element(xml_node)
      Parser::Element.new(
        area: empty_area,
        name: "grapheme",
        certainty: 1,
        value: directional_value(xml_node)
      )
  end

  def pop_directionality_element
      Parser::Element.new(
        area: empty_area,
        name: "grapheme",
        certainty: 1,
        value: pop_directionality_value,
        grouping: "pop"
      )
  end

  def is_rtl(element)
    element.value == 0x200f.chr
  end

  def directional_value(xml_node)
    direction = xml_node.attr('dir')

    if !direction.is_a? String
      direction = direction.try(:value)
    end

    case direction
    when 'rtl'
      0x200f.chr
    else
      0x200e.chr
    end
  end

  def pop_directionality_value
    0x202c.chr
  end

  def to_elements(xml_node, node_class, directional = nil)
    case node_class
    when 'ocr_page'
      [ page_node_to_element(xml_node) ]
    when 'ocr_line'
      els = line_node_to_elements(xml_node, directional)
      @_last_zone = els.first
      els
    when 'ocrx_word'
      word_node_to_elements(xml_node)
    else
      [ ]
    end
  end

  def page_node_to_element(xml_node)
    Parser::Element.new(
      area: node_area(xml_node),
      name: "surface"
    )
  end

  def has_previous_zone
    defined?(@_last_zone) && @_last_zone.present?
  end

  def line_node_to_elements(xml_node, directional)
    line_area = node_area(xml_node)
    pop = pop_directionality_element
    if directional.present? && self.is_rtl(directional)
      pop.area.ulx = line_area.ulx
      pop.area.lrx = line_area.ulx
      directional.area.lrx = line_area.lrx
      directional.area.ulx = line_area.lrx
      directional.area.uly = pop.area.uly = line_area.uly
      directional.area.lry = pop.area.lry =line_area.lry
    else
      pop.area.ulx = line_area.lrx
      pop.area.lrx = line_area.lrx
      directional.area.lrx = line_area.ulx
      directional.area.ulx = line_area.ulx
      directional.area.uly = pop.area.uly = line_area.uly
      directional.area.lry = pop.area.lry = line_area.lry
    end
    [
      (has_previous_zone ? pop : nil),
      Parser::Element.new(
        area: line_area,
        name: "zone"
      ),
      directional
    ].reject(&:nil?)
  end

  def word_node_to_elements(xml_node)
    return [] if word_empty?(xml_node)

    unordered = xml_node.text.chars
    count_all = unordered.count

    visual_indices = Bidi.to_visual_indices(xml_node.text, direction(xml_node))

    visual_indices.each_with_index.lazy.map do |visual_index, logical_index|
      Parser::Element.new(
        area: node_area(xml_node, visual_index, count_all),
        name: "grapheme",
        certainty: node_certainty(xml_node),
        value: unordered[logical_index],
        grouping: xml_node.attr('title')
      )
    end
  end

  def word_empty?(xml_node)
    xml_node.text.strip.codepoints.reject { |cp| cp == 0x200e || cp == 0x200f || cp == 0x202c }.empty?
  end

  def node_certainty(xml_node)
    wconf = xml_node.attr('title').split(';').map(&:strip).find { |m| m[/x_wconf/] }
    wconf.split(' ').last.to_f / 100.0
  end

  def node_area(xml_node, index = nil, count_all = nil)
    title_attr = attr(xml_node, 'title')
    bbox_string = title_attr.split(';').map(&:strip).find { |prop| prop[/bbox/] }
    ulx, uly, lrx, lry = bbox_string.split(' ').drop(1).map(&:to_i)

    if index.present? and count_all.present?
      width = lrx - ulx
      lrx = ulx + (index + 1) * width * 1.0 / count_all
      ulx = ulx + index       * width * 1.0 / count_all
    end

    Area.new(ulx: ulx, uly: uly, lrx: lrx, lry: lry)
  end

  def empty_area
    Area.new(ulx: 0, uly: 0, lrx: 0, lry: 0)
  end

  def xml_page_root
    @_xml ||= Nokogiri::XML(hocr_string).css('.ocr_page')
  end

  # todo: make sure the unicode script list here is exhaustive
  def direction(xml_node)
    /(\p{Arabic}|\p{Hebrew}|\p{Syriac})/.match?(xml_node.text) ? :rtl : :ltr
  end

  private

  def initialize(hocr_string)
    @hocr_string = hocr_string
  end
end
