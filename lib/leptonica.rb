module Leptonica
  module C
    extend FFI::Library
    ffi_lib ['liblept', 'liblept', 'liblept.so.5']

    attach_function :pixRead, [ :string ], :pointer
    attach_function :pixFindSkewAndDeskew, [ :pointer, :int, :pointer, :pointer ], :pointer
    attach_function :pixDestroy, [ :pointer ], :void
    attach_function :pixWriteImpliedFormat, [ :string, :pointer, :int, :int ], :int
    attach_function :dewarpSinglePage, [ :pointer, :int, :int, :int, :pointer, :pointer, :int ], :int
    attach_function :pixBackgroundNormSimple, [ :pointer, :pointer, :pointer ], :pointer
  end

  class Tools
    def self.deskew(in_path, out_path)
      pixels = C.pixRead in_path
      output_pixels = C.pixFindSkewAndDeskew pixels, 4, FFI::Pointer::NULL, FFI::Pointer::NULL

      if output_pixels.null?
        raise StandardError, "Leptonica pixFindSkewAndDeskew failed returning null pointer"
      end

      if C.pixWriteImpliedFormat( out_path, output_pixels, 100, 0 ) != 0
        raise StandardError, "Leptonica failed to write deskewed image"
      end
    rescue
      raise $!
    ensure
      pix_destroy(pixels) if pixels.present? && !pixels.null?
      pix_destroy(output_pixels) if output_pixels.present? && !output_pixels.null?
    end

    def self.dewarp(in_path, out_path)
      pixels = C.pixRead in_path
      normed = C.pixBackgroundNormSimple pixels, FFI::Pointer::NULL, FFI::Pointer::NULL
      output = FFI::MemoryPointer.new :pointer
      output.put_pointer(0, normed)

      if C.dewarpSinglePage( pixels, 0, 1, 1, output, FFI::Pointer::NULL, 0 ) != 0
        raise StandardError, "Leptonica dewarpSinglePage has failed"
      end

      if C.pixWriteImpliedFormat( out_path, normed, 100, 0 ) != 0
        raise StandardError, "Leptonica failed to write dewarped image"
      end

      true
    rescue
      raise $!
    ensure
      pix_destroy(pixels) if pixels.present? && !pixels.null?
      pix_destroy(normed) if normed.present? && !normed.null?
    end

    def self.pix_destroy(pointer)
      pix_pointer = FFI::MemoryPointer.new :pointer
      pix_pointer.put_pointer(0, pointer)
      C.pixDestroy(pix_pointer)
    end
  end

  # dewarping: http://tpgit.github.io/Leptonica/dewarptest_8c_source.html
  # deskewing: https://github.com/OpenPhilology/nidaba/blob/a7e8e547b140738d0270dc9c9e3dc6b09c5a945c/nidaba/plugins/leptonica.py#L191
end
