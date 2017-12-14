module Bidi
  module Lib
    extend FFI::Library
    ffi_lib ['libfribidi', 'libfribidi.so.0', 'libfribidi.so.0.3.6']

    attach_function :fribidi_log2vis, [ :pointer, :int32, :pointer, :pointer, :pointer, :pointer, :pointer ], :bool
    attach_function :fribidi_get_bidi_type, [ :string ], :pointer
  end

  def self.to_visual(text, direction)
    null = FFI::Pointer::NULL

    t = FFI::MemoryPointer.new(:uint32, text.codepoints.count)
    t.put_array_of_uint32(0, text.codepoints)

    pos = FFI::MemoryPointer.new(:int, text.codepoints.count)

    dir_spec = FFI::MemoryPointer.new(:long)
    dir_spec.write_long( direction == :rtl ? 273 : 272)

    success = Lib.fribidi_log2vis(t, text.codepoints.count, dir_spec, null, null, pos, null)

    if success
      positions = pos.read_array_of_int(text.codepoints.count)

      positions.map do |index|
        text[index]
      end.join
    else
      raise StandardError, "Failed to infer the visual ordering for the text"
    end
  end
end
