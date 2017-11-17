module Tesseract
  module Lib
    extend FFI::Library
    # TODO: provide a mechanism of pointing at the correct library
    ffi_lib [ '/home/kamil/local/lib/libleptonica.so.5.1.0' ]
    ffi_lib [ '/home/kamil/local/lib/libtesseract.so.4' ]

    enum :ocr_mode, [
      :tesseract_only, 1,
      :lstm_only,
      :tesseract_lstm_combined,
      :default,
      :cube_only,
      :tesseract_cube_combined
    ]

    attach_function :TessBaseAPICreate, [ ], :pointer
    attach_function :TessBaseAPIDelete, [ :pointer ], :void
    attach_function :TessVersion, [ ], :string
    attach_function :TessBaseAPIInit2, [ :pointer, :string, :string, :ocr_mode ], :int
    attach_function :TessBaseAPISetImage2, [ :pointer, :pointer ], :void
    attach_function :TessBaseAPISetRectangle, [ :pointer, :int, :int, :int, :int ], :void
    attach_function :TessBaseAPIGetUTF8Text, [ :pointer ], :pointer
    attach_function :TessBaseAPIMeanTextConf, [ :pointer ], :int
    attach_function :TessBaseAPIClear, [ :pointer ], :void
    attach_function :TessBaseAPIEnd, [ :pointer ], :void
  end

  class Tools

  end
end
