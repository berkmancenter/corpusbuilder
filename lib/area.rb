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

  def normalize
    @ulx = @ulx.to_f.round
    @uly = @uly.to_f.round
    @lrx = @lrx.to_f.round
    @lry = @lry.to_f.round
  end

  def self.span_boxes(boxes)
    ulx = boxes.map { |box| box[:ulx] }.min
    uly = boxes.map { |box| box[:uly] }.min
    lrx = boxes.map { |box| box[:lrx] }.max
    lry = boxes.map { |box| box[:lry] }.max

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
        raise ArgumentError, "Lower right corner should point at **higher** y value since Y axis points downwards"
      end

      if value.lrx < value.ulx
        raise ArgumentError, "Lower right corner should point at **higher** x value since X axis points to the right"
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
