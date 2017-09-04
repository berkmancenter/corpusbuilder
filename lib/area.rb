class Area
  include Comparable

  attr_accessor :lrx, :lry, :ulx, :uly

  def initialize(options)
    @lrx = options[:lrx].to_i
    @lry = options[:lry].to_i
    @ulx = options[:ulx].to_i
    @uly = options[:uly].to_i
  end

  def <=>(other)
    return nil if other.nil?

    @lrx <=> other.lrx &&
      @lry <=> other.lry &&
      @ulx <=> other.ulx &&
      @uly <=> other.uly
  end

  def to_s
    "<area lrx=#{@lrx} lry=#{@lry} ulx=#{@ulx} uly=#{@uly} />"
  end

  class Serializer
    def self.load(value)
      return nil if value.nil?

      urx, ury, llx, lly = value.gsub(/(\(|\))/, '').split(',').map(&:to_i)

      Area.new lrx: urx, lry: lly, ulx: llx, uly: ury
    end

    def self.dump(value)
      return nil if value.nil?

      # in PG that is: (ur),(ll)
      "((#{value.lrx},#{value.uly}),(#{value.ulx},#{value.lry}))"
    end
  end
end
