module Leptonica
  module Lib
    extend FFI::Library
    ffi_lib ['liblept', 'liblept', 'liblept.so.5']

    attach_function :pixRead, [ :string ], :pointer
    attach_function :pixFindSkewAndDeskew, [ :pointer, :int, :pointer, :pointer ], :pointer
    attach_function :pixDestroy, [ :pointer ], :void
    attach_function :pixWriteImpliedFormat, [ :string, :pointer, :int, :int ], :int
    attach_function :pixBackgroundNormSimple, [ :pointer, :pointer, :pointer ], :pointer
    attach_function :pixConvertRGBToGray, [ :pointer, :float, :float, :float ], :pointer
    attach_function :pixThresholdToBinary, [ :pointer, :int ], :pointer
    attach_function :pixCreateTemplate, [ :pointer ], :pointer
    attach_function :pixExtractTextlines, [ :pointer, :int, :int, :int, :int, :int, :int, :pointer ], :pointer
    attach_function :pixGetWidth, [ :pointer ], :int
    attach_function :pixConvertRGBToGrayMinMax, [ :pointer, :int32 ], :pointer

    attach_function :dewarpSinglePage, [ :pointer, :int, :int, :int, :pointer, :pointer, :int ], :int
    attach_function :dewarpCreate, [ :pointer, :int ], :pointer
    attach_function :dewarpBuildPageModel, [ :pointer, :pointer ], :int
    attach_function :dewarpaApplyDisparity, [ :pointer, :int, :pointer, :int, :int, :int, :pointer, :pointer ], :int
    attach_function :dewarpDestroy, [ :pointer ], :void

    attach_function :dewarpaCreate, [ :int, :int, :int, :int, :int ], :pointer
    attach_function :dewarpaUseBothArrays, [ :pointer, :int32 ], :int32
    attach_function :dewarpaInsertDewarp, [ :pointer, :pointer ], :void
    attach_function :dewarpaDestroy, [ :pointer ], :void
  end

  class Tools
    def self.silent(&block)
      prevout = STDOUT.dup
      preverr = STDERR.dup

      begin
        $stdout.reopen Rails.root.join("log", "leptonica.log"), 'w'
        $stderr.reopen Rails.root.join("log", "leptonica.error.log"), 'w'

        block.call
      ensure
        $stdout.reopen prevout
        $stderr.reopen preverr
      end
    end

    def self.deskew(in_path, out_path)
      silent do
        begin
          if !File.exist?(in_path)
            raise StandardError, "Leptonica::Tools.deskew has been given a path to inexistant file: '#{in_path}'"
          end

          pixels = Lib.pixRead in_path

          if pixels.null?
            raise StandardError, "Leptonica::Tools.deskew couldn't load file: '#{in_path}' (null pointer returned)"
          end

          output_pixels = Lib.pixFindSkewAndDeskew pixels, 4, FFI::Pointer::NULL, FFI::Pointer::NULL

          if output_pixels.null?
            raise StandardError, "Leptonica pixFindSkewAndDeskew failed returning null pointer"
          end

          if Lib.pixWriteImpliedFormat( out_path, output_pixels, 100, 0 ) != 0
            raise StandardError, "Leptonica failed to write deskewed image"
          end
        rescue
          raise $!
        ensure
          pix_destroy(pixels) if pixels.present? && !pixels.null?
          pix_destroy(output_pixels) if output_pixels.present? && !output_pixels.null?
        end
      end
    end

    def self.dewarp(in_path, out_path)
      silent do
        begin
          if !File.exist?(in_path)
            raise StandardError, "Leptonica::Tools.dewarp has been given a path to inexistant file: '#{in_path}'"
          end

          pixels = Lib.pixRead in_path
          normed = Lib.pixBackgroundNormSimple(pixels, FFI::Pointer::NULL, FFI::Pointer::NULL)
          grayed = Lib.pixConvertRGBToGrayMinMax(normed, 2)
          output = Lib.pixThresholdToBinary(grayed, 130)
          output_pointer = FFI::MemoryPointer.new :pointer
          output_pointer.put_pointer(0, output)
          dewarp = FFI::Pointer::NULL
          dewarpa = FFI::Pointer::NULL

          lines = 30
          samples = 2**8

          while lines > 0
            dewarpa = Lib.dewarpaCreate(1, samples, 1, lines, 50)
            Lib.dewarpaUseBothArrays(dewarpa, 1)
            Lib.dewarpaInsertDewarp(dewarpa, dewarp)
            dewarp = Lib.dewarpCreate(output, 0)

            if Lib.dewarpBuildPageModel(dewarp, FFI::Pointer::NULL) != 0
              if lines == 4
                if samples == 8
                  raise StandardError, "Leptonica failed to create the dewarp model for the input image: #{in_path}"
                else
                  lines = 30
                  samples /= 2
                end
              end
            else
              break
            end

            lines -= 1
          end

          if Lib.dewarpaApplyDisparity(dewarpa, 0, pixels, -1, 0, 0, output_pointer, FFI::Pointer::NULL) != 0
            raise StandardError, "Leptonica failed to apply the disparity model in order to dewarp the image"
          end

          output_modified = output_pointer.get_pointer(0)

          if Lib.pixWriteImpliedFormat( out_path, output_modified, 100, 0 ) != 0
            raise StandardError, "Leptonica failed to write dewarped image"
          end

          true
        ensure
          pix_destroy(pixels) if defined?(pixels)
          pix_destroy(normed) if defined?(normed)
          pix_destroy(grayed) if defined?(grayed)
          pix_destroy(converted) if defined?(converted)
          pix_destroy(output) if defined?(output)
          pix_destroy(output_modified) if defined?(output_modified)
          dewarp_destroy(dewarp) if defined?(dewarp)
        end
      end
    end

    def self.dewarp_simple(in_path, out_path)
      silent do
        begin
          pixels = Lib.pixRead in_path
          normed = Lib.pixBackgroundNormSimple pixels, FFI::Pointer::NULL, FFI::Pointer::NULL
          output = FFI::MemoryPointer.new :pointer
          output.put_pointer(0, normed)

          if Lib.dewarpSinglePage( pixels, 0, 1, 1, output, FFI::Pointer::NULL, 0 ) != 0
            raise StandardError, "Leptonica dewarpSinglePage has failed"
          end

          dewarped = output.get_pointer(0)

          if Lib.pixWriteImpliedFormat( out_path, dewarped, 100, 0 ) != 0
            raise StandardError, "Leptonica failed to write dewarped image"
          end

          true
        rescue
          raise $!
        ensure
          pix_destroy(pixels) if defined?(pixels) && pixels.present? && !pixels.null?
          pix_destroy(normed) if defined?(normed) && normed.present? && !normed.null?
          pix_destroy(dewarped) if defined?(dewarped) && dewarped.present? && !dewarped.null?
        end
      end
    end

    def self.dewarp_destroy(pointer)
      pix_pointer = FFI::MemoryPointer.new :pointer
      pix_pointer.put_pointer(0, pointer)
      Lib.dewarpDestroy(pix_pointer)
    end

    def self.dewarpa_destroy(pointer)
      pix_pointer = FFI::MemoryPointer.new :pointer
      pix_pointer.put_pointer(0, pointer)
      Lib.dewarpaDestroy(pix_pointer)
    end

    def self.pix_destroy(pointer)
      pix_pointer = FFI::MemoryPointer.new :pointer
      pix_pointer.put_pointer(0, pointer)
      Lib.pixDestroy(pix_pointer)
    end

    def self.ptaa_destroy(pointer)
      pix_pointer = FFI::MemoryPointer.new :pointer
      pix_pointer.put_pointer(0, pointer)
      Lib.ptaaDestroy(pix_pointer)
    end
  end

  # dewarping: http://tpgit.github.io/Leptonica/dewarptest_8c_source.html
  # deskewing: https://github.com/OpenPhilology/nidaba/blob/a7e8e547b140738d0270dc9c9e3dc6b09c5a945c/nidaba/plugins/leptonica.py#L191
end
