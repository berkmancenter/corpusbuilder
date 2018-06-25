class Area
  include Comparable

  attr_accessor :lrx, :lry, :ulx, :uly

  def initialize(options)
    @lrx = options[:lrx].to_f.round
    @lry = options[:lry].to_f.round
    @ulx = options[:ulx].to_f.round
    @uly = options[:uly].to_f.round

    if @lry < @uly
      raise ArgumentError, "Lower right corner should point at **higher** y value since Y axis points downwards (lry = #{@lry} and uly = #{@uly})"
    end

    if @lrx < @ulx
      raise ArgumentError, "Lower right corner should point at **higher** x value since X axis points to the right (lrx = #{@lrx} and ulx = #{@ulx})"
    end
  end

  def normalize!
    @ulx = @ulx.to_f.round
    @uly = @uly.to_f.round
    @lrx = @lrx.to_f.round
    @lry = @lry.to_f.round

    self
  end

  def include?(other)
    ulx <= other.ulx &&
      lrx >= other.lrx &&
      uly <= other.uly &&
      lry >= other.lry
  end

  def slice(ix, count_all)
    new_width = (width / count_all).round

    Area.new ulx: (ulx + ix * new_width),
      uly: uly,
      lrx: (ulx + (ix + 1) * new_width),
      lry: lry
  end

  def width
    @lrx - @ulx
  end

  def height
    @lry - @uly
  end

  def x
    @ulx
  end

  def y
    @uly
  end

  def [](ix)
    six = ix.to_s

    case six
    when "ulx" then @ulx
    when "lrx" then @lrx
    when "uly" then @uly
    when "lry" then @lry
    end
  end

  def self.span_boxes(boxes)
    ulx = boxes.map { |box| box[:ulx] || box["ulx"] }.map(&:to_f).min
    uly = boxes.map { |box| box[:uly] || box["uly"] }.map(&:to_f).min
    lrx = boxes.map { |box| box[:lrx] || box["lrx"] }.map(&:to_f).max
    lry = boxes.map { |box| box[:lry] || box["lry"] }.map(&:to_f).max

    new ulx: ulx, uly: uly, lrx: lrx, lry: lry
  end

  def self.from_raw_box(raw_box)
    ulx, uly, lrx, lry = raw_box

    new ulx: ulx, uly: uly, lrx: lrx, lry: lry
  end

  def self.span_raw_boxes(boxes)
    ulx = boxes.map { |b| b[0] }.min
    uly = boxes.map { |b| b[1] }.min
    lrx = boxes.map { |b| b[2] }.max
    lry = boxes.map { |b| b[3] }.max

    new ulx: ulx, uly: uly, lrx: lrx, lry: lry
  end

  def overlaps?(other)
    return false if other.nil?

    @uly < other.lry &&
      @lry > other.uly &&
      @ulx < other.lrx &&
      @lrx > other.ulx
  end

  def ==(other)
    return false if other.nil?

    @lrx == other.lrx &&
      @lry == other.lry &&
      @ulx == other.ulx &&
      @uly == other.uly
  end

  def valid?
    lry > uly && lrx > ulx
  end

  def to_s
    Serializer.dump(self)
  end

  class Tree < Grape::Entity
    expose :lrx
    expose :lry
    expose :ulx
    expose :uly
  end

  class Serializer
    def self.load(value)
      return nil if value.nil?

      lrx, lry, ulx, uly = value.gsub(/(\(|\))/, '').split(',').map(&:to_f).map(&:round)

      Area.new lrx: lrx, lry: lry, ulx: ulx, uly: uly
    end

    def self.dump(value)
      return nil if value.nil?

      if value.lry < value.uly
        raise ArgumentError, "Lower right corner should point at **higher** y value since Y axis points downwards (lry = #{value.lry} and uly = #{value.uly})"
      end

      if value.lrx < value.ulx
        raise ArgumentError, "Lower right corner should point at **higher** x value since X axis points to the right (lrx = #{value.lrx} and ulx = #{value.ulx})"
      end

      "((#{value.lrx},#{value.lry}),(#{value.ulx},#{value.uly}))"
    end
  end

  class ArraySerializer
    def self.load(value)
      return nil if value.nil?

      arr = value.is_a?(Array) ? value : value.gsub(/\{|\}/, '').split(';')

      arr.map do |string|
        Serializer.load(string)
      end
    end

    def self.dump(value)
      return nil if value.nil?

      "{#{value.map { |area| Serializer.dump(area) }.join(';')}}"
    end
  end
end
