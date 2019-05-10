module OcrModels
  class InstallKrakenModel < InstallBase
    def env_var
      'KRAKEN_DATA_PREFIX'
    end

    def extension
      '.mlmodel'
    end
  end
end
