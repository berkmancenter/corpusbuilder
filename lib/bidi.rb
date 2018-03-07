module Bidi
  module Lib
    extend FFI::Library
    ffi_lib ['libfribidi', 'libfribidi.so.0', 'libfribidi.so.0.3.6']

    attach_function :fribidi_log2vis, [ :pointer, :int32, :pointer, :pointer, :pointer, :pointer, :pointer ], :bool
    attach_function :fribidi_get_bidi_type, [ :string ], :pointer
    attach_function :fribidi_get_par_direction, [ :pointer, :int32 ], :uint32
    attach_function :fribidi_get_bidi_types, [ :pointer, :int32, :pointer ], :pointer
  end

  def self.to_visual(text, direction)
    positions = to_visual_indices(text, direction)

    positions.map do |index|
      text[index]
    end.join
  end

  def self.to_visual_indices(text, direction)
    null = FFI::Pointer::NULL

    t = FFI::MemoryPointer.new(:uint32, text.codepoints.count)
    t.put_array_of_uint32(0, text.codepoints)

    pos = FFI::MemoryPointer.new(:int, text.codepoints.count)

    dir_spec = FFI::MemoryPointer.new(:long)
    dir_spec.write_long( direction == :rtl ? 273 : 272)

    success = Lib.fribidi_log2vis(t, text.codepoints.count, dir_spec, null, null, pos, null)

    if success
      return pos.read_array_of_int(text.codepoints.count)
    else
      raise StandardError, "Failed to infer the visual ordering of the text"
    end
  end

  def self.to_logical_indices(text, direction)
    null = FFI::Pointer::NULL

    t = FFI::MemoryPointer.new(:uint32, text.codepoints.count)
    t.put_array_of_uint32(0, text.codepoints)

    pos = FFI::MemoryPointer.new(:int, text.codepoints.count)

    dir_spec = FFI::MemoryPointer.new(:long)
    dir_spec.write_long( direction == :rtl ? 273 : 272)

    success = Lib.fribidi_log2vis(t, text.codepoints.count, dir_spec, null, pos, null, null)

    if success
      return pos.read_array_of_int(text.codepoints.count)
    else
      raise StandardError, "Failed to infer the logical ordering of the text"
    end
  end

  def self.infer_direction(text)
    t = FFI::MemoryPointer.new(:uint32, text.codepoints.count)
    t.put_array_of_uint32(0, text.codepoints)

    b = FFI::MemoryPointer.new(:long, text.codepoints.count)

    Lib.fribidi_get_bidi_types(t, text.codepoints.count, b)

    result = Lib.fribidi_get_par_direction(b, text.codepoints.count)

    if result == 273
      :rtl
    elsif result == 272
      :ltr
    else
      :on
    end
  end
end
