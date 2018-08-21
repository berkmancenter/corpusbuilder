# Thanks to:
#
# http://www.simplesystems.org/libtiff/libtiff.html
# https://github.com/bernerdschaefer/tiff/blob/master/lib/tiff/bindings.rb

module Tiff
  module Lib
    extend FFI::Library

    ffi_lib 'libtiff'

    attach_function :_open, :TIFFOpen,
      [ :string, :string ], :pointer

    attach_function :close, :TIFFClose,
      [ :pointer ], :void

    attach_function :get_field, :TIFFGetField,
      [:pointer, :uint, :varargs], :int

    attach_function :read, :TIFFReadRGBAImage,
      [ :pointer, :uint32, :uint32, :pointer, :int ], :int

    attach_function :advance_page, :TIFFReadDirectory,
      [ :pointer ], :int

    class << self
      def open(path, mode)
        File.open(path, mode) {}

        _open(path, mode).tap do |descriptor|
          if descriptor.null?
            raise ArgumentError, "`#{path}` is not a valid TIFF image"
          end
        end
      end
    end
  end

  class Image
    include Finalizable

    attr_accessor :ptr, :closed

    WIDTH_TAG = 256
    HEIGHT_TAG = 257

    def initialize(path, mode = "r")
      @ptr = Lib.open(path, mode)
      @closed = false

      on_finalize do |id|
        self.close
      end
    end

    def pages
      @_pages ||= self.lazy_pages.to_a
    end

    def lazy_pages
      Enumerator::Lazy.new([ 0 ]) do |yielder|
        loop do
          width = self.width
          height = self.height

          data_ptr = FFI::MemoryPointer.new(:uint32, width * height)

          if Lib.read(@ptr, width, height, data_ptr, 1) == 0
            raise StandardError, "Failed to read TIFF image data"
          end

          data = data_ptr.read_array_of_uint32(width * height)

          yielder << Page.new(data, width, height)

          if Lib.advance_page(@ptr) == 0
            break
          end
        end
      end
    end

    def close
      Lib.close(@ptr) if !@closed
      @closed = true
    end

    def width
        width_ptr = FFI::MemoryPointer.new(:int)
        Lib.get_field ptr, WIDTH_TAG, :pointer, width_ptr

        width_ptr.read_int
    end

    def height
        height_ptr = FFI::MemoryPointer.new(:int)
        Lib.get_field ptr, HEIGHT_TAG, :pointer, height_ptr

        height_ptr.read_int
    end

    def self.open(path, mode, &block)
      instance = new(path, mode)

      if block.present?
        block.call(instance)
        instance.close

        return true
      end

      instance
    end

    class Page
      attr_accessor :data, :width, :height

      def initialize(data, width, height)
        @data = data
        @width = width
        @height = height
      end

      def inspect
        "<Tiff::Image::Page width=#{width} height=#{height} data=#{ data.empty? ? '(empty)' : '...' }>"
      end

      def [](x, y)
        Pixel.new(@data[y * @width + x])
      end

      class Pixel
        attr_accessor :abgr

        def initialize(abgr)
          @abgr = abgr
        end

        def r
          (abgr) & 0xff
        end

        def g
          ((abgr) >> 8) & 0xff
        end

        def b
          ((abgr) >> 24) & 0xff
        end
      end
    end
  end
end
