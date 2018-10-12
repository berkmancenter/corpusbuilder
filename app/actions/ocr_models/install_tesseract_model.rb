module OcrModels
  class InstallTesseractModel < InstallBase
    def env_var
      'TESSDATA_PREFIX'
    end

    def extension
      '.traineddata'
    end
  end
end
