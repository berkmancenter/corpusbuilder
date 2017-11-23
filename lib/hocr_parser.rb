# Parses the string containing the hOCR classifier output.
# Doesn't work with streams as is turned out the "traditional" approach is
# sufficiently performant and didn't eat that lot of memory
class HocrParser < Parser
  attr_accessor :element_parser, :hocr_string, :yielder, :bidi

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
    Rails.logger.debug "HocrParser.elements with node being: #{node.class}"

    node_class = attr(node, "class")

    Enumerator::Lazy.new([ 0 ]) do |yielder, _|
      to_elements(node, node_class, directional).each do |element|
        yielder << element
      end

      if node_class != 'ocrx_word'
        child_nodes = 0
        child_selector = node_class

        while child_nodes == 0 && child_selector != nil
          child_selector = next_level ".#{node_class}"
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
        end
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
        value: pop_directionality_value
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
    Rails.logger.debug "Node text: #{xml_node.text}"

    unordered = xml_node.text.chars
    ordered = bidi.to_visual(xml_node.text, direction(xml_node)).chars
    ordered_codepoints = ordered.map(&:codepoints).flatten
    count_all = ordered.count

    Rails.logger.debug "Unordered list of graphemes: #{unordered.try(:inspect)}"
    Rails.logger.debug "Ordered list of graphemes: #{ordered.try(:inspect)}"

    used_indexes = Set.new

    indexes_map = Proc.new do |char|
      codepoint = char.codepoints.first

      ordered.each_index.lazy.select do |i|
        ordered_codepoints[i] == codepoint
      end
    end

    ordered_index = Proc.new do |char, depth = 0|
      filtered = indexes_map.call(char).drop_while do |i|
        used_indexes.include? i
      end

      index = begin
        filtered.next
      rescue StopIteration
        Rails.logger.debug "StopIteration for the grapheme: ( #{char.codepoints.first} ) with depth: #{depth} for the unordered list being #{unordered} the ordered being #{ordered} and the used_indexes being #{used_indexes.inspect}"
        Rails.logger.debug "The indexes map for the grapheme: #{indexes_map.call(char).to_a}"
        Rails.logger.debug "The ordered codepoints: #{ordered.map(&:codepoints).flatten}"
        mirrored_codepoints = $mirrorMap[char.codepoints.first]

        if mirrored_codepoints.present?
          mirrored_char = mirrored_codepoints.first.chr

          ordered_index.call(mirrored_char, depth + 1)
        end
      end

      used_indexes << index

      index
    end

    unordered.lazy.map do |char|
      Parser::Element.new(
        area: node_area(xml_node, ordered_index.call(char), count_all),
        name: "grapheme",
        certainty: node_certainty(xml_node),
        value: char,
        grouping: xml_node.attr('title')
      )
    end
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
    /(\p{Arabic}|\p{Hebrew}|\p{Syriac})/.match?(xml_node.text) ? "R" : "L"
  end

  private

  def initialize(hocr_string)
    @hocr_string = hocr_string
    @bidi = Bidi.new
  end
end
