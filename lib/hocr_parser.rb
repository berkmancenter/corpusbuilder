class HocrParser < Parser
  attr_accessor :element_parser, :hocr_string, :yielder

  def self.parse(hocr_string)
    # todo: make the following work with streams and make
    # the string case performant too
    new(hocr_string.gsub(/\<\?.*$/, ''))
  end

  def elements
    # todo: implement me
    [].lazy
  end

  private

  def initialize(hocr_string)
    @hocr_string = hocr_string
  end

end
